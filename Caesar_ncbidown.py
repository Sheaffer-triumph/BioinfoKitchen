import requests
import argparse         # 导入argparse模块用于处理命令行参数

parser = argparse.ArgumentParser(description="Search NCBI database")
parser.add_argument("-i", "--id_file", type=str, help="file containing IDs to search")

# 解析命令行参数
args = parser.parse_args()

# 从文件中读取ID
with open(args.id_file, "r") as f:
    id_list = [line.strip() for line in f]

for id in id_list:
    url = f"https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/{id}/download?include_annotation_type=GENOME_FASTA&include_annotation_type=GENOME_GFF&include_annotation_type=RNA_FASTA&include_annotation_type=CDS_FASTA&include_annotation_type=PROT_FASTA&include_annotation_type=SEQUENCE_REPORT&hydrated=FULLY_HYDRATED"
    response = requests.get(url)
    response.raise_for_status()
    with open(f"{id}.zip", "wb") as out_file:  # 请替换为你想要的输出文件名
        out_file.write(response.content)