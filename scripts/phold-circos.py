#!/usr/bin/env python3
"""
phold_plot_standalone.py

独立的 Circos 绘图脚本，基于 phold 的 plot 功能。
输入: phold 输出的 .gbk 文件
输出: PDF 格式的 Circos 图

用法:
    python phold_plot_standalone.py -i phold.gbk -o output.pdf
    python phold_plot_standalone.py -i phold.gbk -o output.pdf --dpi 600 --label_size 6
    python phold_plot_standalone.py -i phold.gbk -o output.pdf --no_labels
"""

import argparse
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import matplotlib
matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
from Bio import SeqIO, SeqUtils
from Bio.Seq import Seq
from Bio.SeqFeature import SeqFeature
from matplotlib.lines import Line2D
from matplotlib.patches import Patch
from pycirclize import Circos
from pycirclize.parser import Genbank


# ============================================================
# 功能分类颜色配置
# ============================================================
CATEGORY_CONFIG = {
    "acr_defense_vfdb_card": {"col": "#FF0000", "label": "VF/AMR/ACR/DF"},
    "unk":                   {"col": "#AAAAAA", "label": "Unknown Function"},
    "other":                 {"col": "#4deeea", "label": "Other Function"},
    "tail":                  {"col": "#74ee15", "label": "Tail"},
    "transcription":         {"col": "#ffe700", "label": "Transcription Regulation"},
    "dna":                   {"col": "#f000ff", "label": "DNA/RNA & nucleotide\nmetabolism"},
    "lysis":                 {"col": "#001eff", "label": "Lysis"},
    "moron":                 {"col": "#8900ff", "label": "Moron, auxiliary metabolic\ngene & host takeover"},
    "int":                   {"col": "#E0B0FF", "label": "Integration & excision"},
    "head":                  {"col": "#ff008d", "label": "Head & packaging"},
    "con":                   {"col": "#5A5A5A", "label": "Connector"},
}

EXTRAS_COLOR = "black"
TRNA_COLOR = "#FF6600"


def parse_args():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(
        description="从 phold 输出的 GenBank 文件生成 Circos 圆形基因组图 (PDF)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  python phold_plot_standalone.py -i phold.gbk -o output.pdf
  python phold_plot_standalone.py -i phold.gbk -o output.pdf --dpi 600
  python phold_plot_standalone.py -i phold.gbk -o output.pdf --title "My Phage"
  python phold_plot_standalone.py -i phold.gbk -o output.pdf --no_labels
        """,
    )
    parser.add_argument(
        "-i", "--input", required=True, type=str,
        help="输入的 GenBank (.gbk) 文件路径"
    )
    parser.add_argument(
        "-o", "--output", required=True, type=str,
        help="输出的 PDF 文件路径"
    )
    parser.add_argument(
        "--contig", type=str, default=None,
        help="指定要绘制的 contig ID。默认绘制第一个 contig"
    )
    parser.add_argument(
        "--title", type=str, default=None,
        help="图的标题。默认使用 contig ID"
    )
    parser.add_argument(
        "--title_size", type=float, default=14,
        help="标题字体大小 (默认: 14)"
    )
    parser.add_argument(
        "--dpi", type=int, default=300,
        help="输出分辨率 (默认: 300)"
    )
    parser.add_argument(
        "--label_size", type=int, default=6,
        help="标签字体大小 (默认: 6)"
    )
    parser.add_argument(
        "--interval", type=int, default=None,
        help="x 轴刻度间隔 (bp)。默认自动计算"
    )
    parser.add_argument(
        "--max_label_width", type=int, default=15,
        help="标签每行最大字符数，超过自动换行 (默认: 15)"
    )
    parser.add_argument(
        "--label_hypotheticals", action="store_true", default=False,
        help="是否标注 hypothetical protein (默认: 否)"
    )
    parser.add_argument(
        "--remove_other_features_labels", action="store_true", default=False,
        help="是否移除 tRNA/tmRNA/CRISPR 的文字标签 (默认: 否，即显示)"
    )
    parser.add_argument(
        "--no_labels", action="store_true", default=False,
        help="不显示任何 CDS/tRNA 标签 (默认: 否)"
    )
    parser.add_argument(
        "--label_force_list", nargs="*", default=[],
        help="强制标注的 feature ID 列表"
    )
    parser.add_argument(
        "--also_png", action="store_true", default=False,
        help="同时输出 PNG 格式"
    )
    parser.add_argument(
        "--also_svg", action="store_true", default=False,
        help="同时输出 SVG 格式"
    )

    return parser.parse_args()


def auto_interval(seq_len: int) -> int:
    """根据序列长度自动计算合适的刻度间隔"""
    if seq_len <= 5000:
        return 1000
    elif seq_len <= 20000:
        return 2000
    elif seq_len <= 50000:
        return 5000
    elif seq_len <= 100000:
        return 10000
    elif seq_len <= 500000:
        return 50000
    else:
        return 100000


def wrap_label(text: str, max_width: int = 15) -> str:
    """
    对标签文本按单词边界进行换行处理，确保每行不超过 max_width 个字符。
    
    例如:
        "terminase large subunit" -> "terminase large\nsubunit"
        "single strand DNA binding protein" -> "single strand\nDNA binding\nprotein"
        "dsDNA binding protein" -> "dsDNA binding\nprotein"
    """
    if len(text) <= max_width:
        return text

    words = text.split()
    lines = []
    current_line = ""

    for word in words:
        if current_line == "":
            current_line = word
        elif len(current_line) + 1 + len(word) <= max_width:
            current_line += " " + word
        else:
            lines.append(current_line)
            current_line = word

    if current_line:
        lines.append(current_line)

    return "\n".join(lines)


def classify_cds_feature(feature: SeqFeature) -> str:
    """
    根据 feature 的 qualifiers 将 CDS 分类到对应的功能类别。
    兼容 phold 格式和普通 GenBank 格式。
    """
    phrog_val = feature.qualifiers.get("phrog", [""])[0].lower()
    function_val = feature.qualifiers.get("function", [""])[0].lower()

    if any(kw in phrog_val for kw in ["vfdb", "card", "acr", "defensefinder"]):
        return "acr_defense_vfdb_card"

    if function_val:
        if function_val == "unknown function":
            return "unk"
        elif function_val == "other":
            return "other"
        elif function_val == "tail":
            return "tail"
        elif function_val == "transcription regulation":
            return "transcription"
        elif "dna" in function_val or "rna" in function_val:
            return "dna"
        elif function_val == "lysis":
            return "lysis"
        elif "moron" in function_val:
            return "moron"
        elif function_val == "integration and excision":
            return "int"
        elif function_val == "head and packaging":
            return "head"
        elif function_val == "connector":
            return "con"

    product_val = feature.qualifiers.get("product", [""])[0].lower()
    if not product_val or "hypothetical" in product_val or "unknown" in product_val:
        return "unk"

    if any(kw in product_val for kw in ["tail", "baseplate", "fiber"]):
        return "tail"
    elif any(kw in product_val for kw in ["capsid", "head", "portal", "terminase", "packaging"]):
        return "head"
    elif any(kw in product_val for kw in ["lysin", "holin", "lysis", "endolysin", "spanin"]):
        return "lysis"
    elif any(kw in product_val for kw in ["integrase", "excision", "recombinase"]):
        return "int"
    elif any(kw in product_val for kw in ["repressor", "anti-repressor", "transcription", "sigma"]):
        return "transcription"
    elif any(kw in product_val for kw in ["dna", "rna", "nuclease", "helicase", "polymerase", "primase", "ligase"]):
        return "dna"
    elif any(kw in product_val for kw in ["connector", "neck"]):
        return "con"

    return "other"


def thin_out_features(
    pos_list: List[float],
    labels: List[str],
    length_list: List[float],
    min_distance: int = 500,
) -> Tuple[List[float], List[str], List[float]]:
    """稀疏化特征标签，避免重叠。"""
    if len(pos_list) == 0:
        return pos_list, labels, length_list

    sorted_indices = sorted(range(len(pos_list)), key=lambda i: pos_list[i])

    filtered_indices = [sorted_indices[0]]
    for i in range(1, len(sorted_indices)):
        idx = sorted_indices[i]
        last_idx = filtered_indices[-1]
        if pos_list[idx] > (pos_list[last_idx] + min_distance):
            filtered_indices.append(idx)

    pos_list = [pos_list[i] for i in filtered_indices]
    labels = [labels[i] for i in filtered_indices]
    length_list = [length_list[i] for i in filtered_indices]

    return pos_list, labels, length_list


def extract_feature_positions(
    features: List[SeqFeature], label_text: str
) -> Tuple[List[float], List[str], List[float]]:
    """从 feature 列表中提取位置、标签和长度信息"""
    pos_list, labels, length_list = [], [], []
    for f in features:
        start = int(f.location.start)
        end = int(f.location.end)
        pos = (start + end) / 2.0
        length = end - start
        pos_list.append(pos)
        labels.append(label_text)
        length_list.append(length)
    return pos_list, labels, length_list


def load_gbk_data(gbk_path: str, target_contig: Optional[str] = None):
    """加载 GenBank 文件，返回绘图所需的所有数据。"""
    gbk_path = Path(gbk_path)
    if not gbk_path.exists():
        print(f"错误: 文件不存在: {gbk_path}", file=sys.stderr)
        sys.exit(1)

    records = list(SeqIO.parse(str(gbk_path), "genbank"))
    if len(records) == 0:
        print(f"错误: GenBank 文件中没有找到任何记录: {gbk_path}", file=sys.stderr)
        sys.exit(1)

    all_contig_ids = [r.id for r in records]
    print(f"[INFO] 文件中包含 {len(records)} 个 contig: {all_contig_ids}")

    if target_contig:
        record = None
        for r in records:
            if r.id == target_contig:
                record = r
                break
        if record is None:
            print(
                f"错误: 找不到指定的 contig '{target_contig}'。"
                f"可用的 contig: {all_contig_ids}",
                file=sys.stderr,
            )
            sys.exit(1)
    else:
        record = records[0]

    contig_id = record.id
    contig_sequence = record.seq
    seq_len = len(contig_sequence)
    features = list(record.features)

    print(f"[INFO] 选中 contig: {contig_id} (长度: {seq_len} bp)")
    print(f"[INFO] 总 feature 数: {len(features)}")

    feature_types = {}
    for f in features:
        feature_types[f.type] = feature_types.get(f.type, 0) + 1
    for ft, count in sorted(feature_types.items()):
        print(f"  - {ft}: {count}")

    gbk = Genbank(str(gbk_path))

    return contig_id, contig_sequence, seq_len, features, gbk, all_contig_ids


def is_unknown_product(label: str) -> bool:
    """
    判断一个 product 标签是否属于 unknown/hypothetical 类别。
    返回 True 表示这是一个"未知"注释，默认不标注。
    """
    if not label:
        return True
    label_lower = label.lower().strip()
    unknown_keywords = [
        "hypothetical",
        "unknown",
        "uncharacterized",
        "putative protein",
        "predicted protein",
        "phage protein",
    ]
    for kw in unknown_keywords:
        if label_lower.startswith(kw) or label_lower == kw:
            return True
    # 如果 product 仅仅是很短的无意义名称
    if len(label_lower) <= 2:
        return True
    return False


def create_circos_plot(
    contig_id: str,
    contig_sequence: Seq,
    seq_len: int,
    features: List[SeqFeature],
    gbk: Genbank,
    interval: int,
    title_size: float,
    plot_title: str,
    max_label_width: int,
    output_pdf: Path,
    dpi: int,
    label_size: int,
    label_hypotheticals: bool,
    remove_other_features_labels: bool,
    label_force_list: List[str],
    no_labels: bool = False,
    also_png: bool = False,
    also_svg: bool = False,
) -> None:
    """创建 Circos 圆形基因组图并保存为 PDF。"""

    # ============================
    # 初始化 Circos
    # ============================
    circos = Circos(sectors={contig_id: seq_len})
    circos.text(plot_title, size=int(title_size), r=190)

    sector = circos.get_sector(contig_id)
    cds_track = sector.add_track((70, 80))
    cds_track.axis(fc="#EEEEEE", ec="none")

    # ============================
    # 初始化数据字典
    # ============================
    data_dict = {}
    for key, cfg in CATEGORY_CONFIG.items():
        data_dict[key] = {"col": cfg["col"], "fwd_list": [], "rev_list": []}

    # ============================
    # 分类 features
    # ============================
    fwd_features = [f for f in features if f.location.strand == 1]
    rev_features = [f for f in features if f.location.strand == -1]
    cds_features = [f for f in features if f.type == "CDS"]
    trna_features = [f for f in features if f.type == "tRNA"]
    tmrna_features = [f for f in features if f.type == "tmRNA"]
    crispr_features = [f for f in features if f.type == "repeat_region"]

    print(f"[INFO] CDS: {len(cds_features)}, tRNA: {len(trna_features)}, "
          f"tmRNA: {len(tmrna_features)}, CRISPR: {len(crispr_features)}")

    for f in fwd_features:
        if f.type == "CDS":
            category = classify_cds_feature(f)
            data_dict[category]["fwd_list"].append(f)

    for f in rev_features:
        if f.type == "CDS":
            category = classify_cds_feature(f)
            data_dict[category]["rev_list"].append(f)

    # ============================
    # 绘制 CDS 箭头
    # ============================
    for key in data_dict:
        cds_track.genomic_features(
            data_dict[key]["fwd_list"],
            plotstyle="arrow",
            r_lim=(75, 80),
            fc=data_dict[key]["col"],
        )
        cds_track.genomic_features(
            data_dict[key]["rev_list"],
            plotstyle="arrow",
            r_lim=(70, 75),
            fc=data_dict[key]["col"],
        )

    # ============================
    # 绘制 tRNA/tmRNA/CRISPR 箭头
    # ============================
    fwd_trna_only = [f for f in fwd_features if f.type == "tRNA"]
    rev_trna_only = [f for f in rev_features if f.type == "tRNA"]
    fwd_tmrna_only = [f for f in fwd_features if f.type == "tmRNA"]
    rev_tmrna_only = [f for f in rev_features if f.type == "tmRNA"]

    if fwd_trna_only:
        cds_track.genomic_features(
            fwd_trna_only, plotstyle="arrow", r_lim=(75, 80), fc=TRNA_COLOR,
        )
    if rev_trna_only:
        cds_track.genomic_features(
            rev_trna_only, plotstyle="arrow", r_lim=(70, 75), fc=TRNA_COLOR,
        )
    if fwd_tmrna_only:
        cds_track.genomic_features(
            fwd_tmrna_only, plotstyle="arrow", r_lim=(75, 80), fc=EXTRAS_COLOR,
        )
    if rev_tmrna_only:
        cds_track.genomic_features(
            rev_tmrna_only, plotstyle="arrow", r_lim=(70, 75), fc=EXTRAS_COLOR,
        )

    fwd_crispr = [f for f in fwd_features if f.type == "repeat_region"]
    rev_crispr = [f for f in rev_features if f.type == "repeat_region"]
    if fwd_crispr:
        cds_track.genomic_features(
            fwd_crispr, plotstyle="arrow", r_lim=(75, 80), fc=EXTRAS_COLOR
        )
    if rev_crispr:
        cds_track.genomic_features(
            rev_crispr, plotstyle="arrow", r_lim=(70, 75), fc=EXTRAS_COLOR
        )

    # ============================
    # 标签处理
    # ============================
    if not no_labels:
        # ------ tRNA / tmRNA / CRISPR 标签 ------
        if not remove_other_features_labels:
            # tRNA 标签：尝试获取详细信息
            pos_trna, lbl_trna, len_trna = extract_feature_positions(
                trna_features, "tRNA"
            )
            for i, f in enumerate(trna_features):
                product = f.qualifiers.get("product", [""])[0]
                note = f.qualifiers.get("note", [""])[0]
                if product and "tRNA" in product:
                    lbl_trna[i] = product
                elif note:
                    lbl_trna[i] = f"tRNA({note})"

            pos_trna, lbl_trna, len_trna = thin_out_features(
                pos_trna, lbl_trna, len_trna, min_distance=500
            )

            # tmRNA 标签
            pos_tmrna, lbl_tmrna, len_tmrna = extract_feature_positions(
                tmrna_features, "tmRNA"
            )
            pos_tmrna, lbl_tmrna, len_tmrna = thin_out_features(
                pos_tmrna, lbl_tmrna, len_tmrna, min_distance=500
            )

            # CRISPR 标签
            pos_crispr, lbl_crispr, len_crispr = extract_feature_positions(
                crispr_features, "CRISPR"
            )
            pos_crispr, lbl_crispr, len_crispr = thin_out_features(
                pos_crispr, lbl_crispr, len_crispr, min_distance=500
            )

        # ------ CDS 标签：显示所有非 unknown 的 CDS ------
        pos_list, labels, length_list = [], [], []
        for f in cds_features:
            start = int(f.location.start)
            end = int(f.location.end)
            pos = (start + end) / 2.0
            length = end - start
            label = f.qualifiers.get("product", [""])[0]
            feat_id = f.qualifiers.get("ID", [""])[0]
            if not feat_id:
                feat_id = f.qualifiers.get("locus_tag", [""])[0]

            # 判断是否要跳过
            if feat_id in label_force_list:
                # 强制列表中的一定显示
                label = wrap_label(label, max_label_width)
                pos_list.append(pos)
                labels.append(label)
                length_list.append(length)
                continue

            if not label_hypotheticals:
                if is_unknown_product(label):
                    continue  # 跳过 unknown/hypothetical

            # ===== 关键改动：不再截断，而是换行 =====
            label = wrap_label(label, max_label_width)
            pos_list.append(pos)
            labels.append(label)
            length_list.append(length)

        print(f"[INFO] 将标注 {len(pos_list)} 个 CDS 标签")

        # 绘制 CDS 标签
        if pos_list:
            cds_track.xticks(
                pos_list,
                labels,
                label_orientation="vertical",
                show_bottom_line=True,
                label_size=label_size,
                line_kws=dict(ec="grey"),
            )

        # 绘制其他特征标签
        if not remove_other_features_labels:
            if pos_trna:
                cds_track.xticks(
                    pos_trna,
                    lbl_trna,
                    label_orientation="vertical",
                    show_bottom_line=True,
                    label_size=label_size,
                    line_kws=dict(ec="grey"),
                )
            if pos_tmrna:
                cds_track.xticks(
                    pos_tmrna,
                    lbl_tmrna,
                    label_orientation="vertical",
                    show_bottom_line=True,
                    label_size=label_size,
                    line_kws=dict(ec="grey"),
                )
            if pos_crispr:
                cds_track.xticks(
                    pos_crispr,
                    lbl_crispr,
                    label_orientation="vertical",
                    show_bottom_line=True,
                    label_size=label_size,
                    line_kws=dict(ec="grey"),
                )

    # ============================
    # GC Content
    # ============================
    gc_content_track = sector.add_track((42.5, 60))
    pos_gc, gc_contents = gbk.calc_gc_content(seq=contig_sequence)
    gc_mean = SeqUtils.gc_fraction(contig_sequence) * 100
    gc_contents = gc_contents - gc_mean
    positive_gc = np.where(gc_contents > 0, gc_contents, 0)
    negative_gc = np.where(gc_contents < 0, gc_contents, 0)
    abs_max_gc = np.max(np.abs(gc_contents))
    vmin, vmax = -abs_max_gc, abs_max_gc
    gc_content_track.fill_between(
        pos_gc, positive_gc, 0, vmin=vmin, vmax=vmax, color="black"
    )
    gc_content_track.fill_between(
        pos_gc, negative_gc, 0, vmin=vmin, vmax=vmax, color="grey"
    )

    # ============================
    # GC Skew
    # ============================
    gc_skew_track = sector.add_track((25, 42.5))
    pos_skew, gc_skews = gbk.calc_gc_skew(seq=contig_sequence)
    positive_skew = np.where(gc_skews > 0, gc_skews, 0)
    negative_skew = np.where(gc_skews < 0, gc_skews, 0)
    abs_max_skew = np.max(np.abs(gc_skews))
    vmin_s, vmax_s = -abs_max_skew, abs_max_skew
    gc_skew_track.fill_between(
        pos_skew, positive_skew, 0, vmin=vmin_s, vmax=vmax_s, color="green"
    )
    gc_skew_track.fill_between(
        pos_skew, negative_skew, 0, vmin=vmin_s, vmax=vmax_s, color="purple"
    )

    # ============================
    # 位置刻度
    # ============================
    cds_track.xticks_by_interval(
        interval=int(interval),
        outer=False,
        show_bottom_line=False,
        label_formatter=lambda v: f"{v / 1000:.0f} Kb",
        label_orientation="vertical",
        line_kws=dict(ec="grey"),
        label_size=7,
    )

    # ============================
    # 图例
    # ============================
    handle_phrogs = []
    legend_order = [
        "unk", "other", "transcription", "dna", "lysis",
        "moron", "int", "head", "con", "tail", "acr_defense_vfdb_card",
    ]
    for key in legend_order:
        handle_phrogs.append(
            Patch(color=CATEGORY_CONFIG[key]["col"], label=CATEGORY_CONFIG[key]["label"])
        )

    fig = circos.plotfig()

    phrog_legend = circos.ax.legend(
        handles=handle_phrogs,
        bbox_to_anchor=(0.10, 1.185),
        fontsize=9.5,
        loc="center",
        title="PHROG CDS",
        handlelength=2,
    )
    circos.ax.add_artist(phrog_legend)

    handle_gc_content = [
        Line2D([], [], color="black", label="Positive GC Content",
               marker="^", ms=6, ls="None"),
        Line2D([], [], color="grey", label="Negative GC Content",
               marker="v", ms=6, ls="None"),
    ]
    gc_legend_cont = circos.ax.legend(
        handles=handle_gc_content,
        bbox_to_anchor=(0.92, 1.30),
        loc="center",
        fontsize=9.5,
        title="GC Content",
        handlelength=2,
    )
    circos.ax.add_artist(gc_legend_cont)

    handle_gc_skew = [
        Line2D([], [], color="green", label="Positive GC Skew",
               marker="^", ms=6, ls="None"),
        Line2D([], [], color="purple", label="Negative GC Skew",
               marker="v", ms=6, ls="None"),
    ]
    gc_legend_skew = circos.ax.legend(
        handles=handle_gc_skew,
        bbox_to_anchor=(0.92, 1.20),
        loc="center",
        fontsize=9.5,
        title="GC Skew",
        handlelength=2,
    )
    circos.ax.add_artist(gc_legend_skew)

    handle_other_features = [
        Patch(color=TRNA_COLOR, label="tRNA"),
        Patch(color=EXTRAS_COLOR, label="tmRNA/CRISPR"),
    ]
    other_features_legend = circos.ax.legend(
        handles=handle_other_features,
        bbox_to_anchor=(0.92, 1.10),
        loc="center",
        fontsize=9.5,
        title="Other Features",
        handlelength=2,
    )
    circos.ax.add_artist(other_features_legend)

    box = circos.ax.get_position()
    circos.ax.set_position([box.x0, box.y0, box.width * 0.65, box.height * 0.9])

    # ============================
    # 保存输出
    # ============================
    output_pdf = Path(output_pdf)

    fig.savefig(str(output_pdf), format="pdf", dpi=dpi, bbox_inches="tight")
    print(f"[INFO] PDF 已保存: {output_pdf}")

    if also_png:
        png_path = output_pdf.with_suffix(".png")
        fig.savefig(str(png_path), dpi=dpi, bbox_inches="tight")
        print(f"[INFO] PNG 已保存: {png_path}")

    if also_svg:
        svg_path = output_pdf.with_suffix(".svg")
        fig.savefig(str(svg_path), format="svg", dpi=dpi, bbox_inches="tight")
        print(f"[INFO] SVG 已保存: {svg_path}")

    plt.close(fig)


def main():
    args = parse_args()

    contig_id, contig_sequence, seq_len, features, gbk, all_contig_ids = load_gbk_data(
        args.input, args.contig
    )

    interval = args.interval if args.interval else auto_interval(seq_len)
    plot_title = args.title if args.title else contig_id

    create_circos_plot(
        contig_id=contig_id,
        contig_sequence=contig_sequence,
        seq_len=seq_len,
        features=features,
        gbk=gbk,
        interval=interval,
        title_size=args.title_size,
        plot_title=plot_title,
        max_label_width=args.max_label_width,
        output_pdf=args.output,
        dpi=args.dpi,
        label_size=args.label_size,
        label_hypotheticals=args.label_hypotheticals,
        remove_other_features_labels=args.remove_other_features_labels,
        label_force_list=args.label_force_list,
        no_labels=args.no_labels,
        also_png=args.also_png,
        also_svg=args.also_svg,
    )

    print("[INFO] 绘图完成!")


if __name__ == "__main__":
    main()
    