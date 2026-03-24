#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""蓍草起卦模拟器 - 四营十八变"""

import random
from typing import List, Tuple

# ============ 数据定义 ============
# 四种爻值
OLD_YIN = 6      # 老阴（变）
YOUNG_YANG = 7   # 少阳
YOUNG_YIN = 8    # 少阴
OLD_YANG = 9     # 老阳（变）

# 变爻集合
CHANGING = {OLD_YIN, OLD_YANG}

# 爻的符号和名称
SYMBOLS = {
    OLD_YIN: "- -",
    YOUNG_YANG: "───",
    YOUNG_YIN: "- -",
    OLD_YANG: "───",
}

NAMES = {
    OLD_YIN: "老阴",
    YOUNG_YANG: "少阳",
    YOUNG_YIN: "少阴",
    OLD_YANG: "老阳",
}

# 六爻的位置名
POSITIONS = ["初爻", "二爻", "三爻", "四爻", "五爻", "上爻"]

# ANSI颜色
RED = "\033[91m"
RESET = "\033[0m"


# ============ 核心算法 ============
def mod4_or_4(n: int) -> int:
    """
    模4运算，但0视为4
    这是蓍草算法的规则：余数为0时取4
    """
    r = n % 4
    return r if r else 4


def split_sticks(sticks: int) -> Tuple[int, int]:
    """
    正态分布模拟随机分堆，每次随机标准差
    
    物理模型：
    - 每次分堆的"随意程度"不同（二阶随机性）
    - 标准差范围：[sticks/10, sticks/4]
      * sticks/10：较专注时，分布集中
      * sticks/4：较随意时，分布分散
    """
    mean = sticks / 2
    std = random.uniform(sticks / 10, sticks / 4)
    
    left = int(random.gauss(mean, std))
    left = max(1, min(sticks - 1, left))
    
    return left, sticks - left


def one_round(sticks: int) -> int:
    """
    执行一轮变化（四营）：
    1. 分二
    2. 挂一
    3. 揲四（左）
    4. 揲四（右）
    5. 归奇
    """
    left, right = split_sticks(sticks)
    right -= 1  # 挂一
    removed = 1 + mod4_or_4(left) + mod4_or_4(right)
    return sticks - removed


def cast_yao() -> int:
    """三变成一爻"""
    sticks = 49
    sticks = one_round(sticks)  # 第一变
    sticks = one_round(sticks)  # 第二变
    sticks = one_round(sticks)  # 第三变
    return sticks // 4


def cast_hexagram() -> List[int]:
    """六爻成卦（从下到上）"""
    return [cast_yao() for _ in range(6)]


# ============ 变换逻辑 ============
def transform_yao(yao: int) -> int:
    """
    变爻转换：老阴变少阳，老阳变少阴
    不变爻保持不变
    """
    if yao == OLD_YIN:
        return YOUNG_YANG
    if yao == OLD_YANG:
        return YOUNG_YIN
    return yao


def transform_hexagram(hexagram: List[int]) -> List[int]:
    """计算之卦"""
    return [transform_yao(y) for y in hexagram]


# ============ 显示逻辑 ============
def colorize(text: str) -> str:
    """给文本上色（红色）"""
    return f"{RED}{text}{RESET}"


def format_yao(yao: int, position: str) -> str:
    """
    格式化单个爻的显示
    变爻用红色标记
    """
    symbol = SYMBOLS[yao]
    name = NAMES[yao]
    
    if yao in CHANGING:
        symbol = colorize(symbol)
        num = colorize(f"[{yao}]")
        name = colorize(name)
    else:
        num = f"[{yao}]"
    
    return f"{position}:  {symbol}   {num}  {name}"


def print_hexagram(hexagram: List[int], title: str = "本卦") -> None:
    """
    打印卦象（从上到下显示）
    注：hexagram数组是从下到上存储的
    """
    print(f"\n{title}（从下到上）：")
    print("=" * 50)
    
    # 倒序遍历：index 5->0 对应 上爻->初爻
    for i in range(5, -1, -1):
        print(format_yao(hexagram[i], POSITIONS[i]))
    
    print("=" * 50)


# ============ 主程序 ============
def main():
    """主函数"""
    print("蓍草起卦模拟器")
    print("使用正态分布+随机标准差模拟真实随机分堆\n")
    
    hexagram = cast_hexagram()
    print(f"原始数据: {hexagram}")
    
    print_hexagram(hexagram, "本卦")
    
    # 有变爻才显示之卦
    if any(y in CHANGING for y in hexagram):
        transformed = transform_hexagram(hexagram)
        print_hexagram(transformed, "之卦")


if __name__ == "__main__":
    main()
