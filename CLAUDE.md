# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is **BioinfoKitchen**, a bioinformatics documentation repository and utility script collection. The main content is in Chinese (README.md) and covers Linux command-line basics, bioinformatics software installation guides, and analysis workflows.

## Repository Structure

```
/
├── README.md           # Main documentation (Chinese) - comprehensive Linux & bioinformatics guide
└── scripts/            # Utility scripts for bioinformatics tasks
    ├── phagex          # Phage genome assembly and annotation pipeline
    ├── phagex.json     # Configuration file with tool paths for phagex
    ├── dcp             # DCS cloud batch job submission tool
    ├── autoqsub        # Automatic qsub job submission with disk quota management
    ├── phold-circos.py # Phage genome circular visualization (based on phold)
    ├── yi.py           # I Ching (周易) divination simulator
    ├── treescan.py     # Directory structure scanner (outputs JSON)
    ├── restruct.py     # Directory structure reconstructor
    └── pytorch_cudatest.py  # PyTorch CUDA environment tester
```

## Key Scripts Usage

### phagex (Phage Analysis Pipeline)
Main pipeline for phage genome assembly and annotation. Requires a JSON config file with tool paths.

```bash
# Full pipeline (QC + assembly + annotation)
./phagex full -1 R1.fq -2 R2.fq -i phage001 -o result -t 16

# Only assembly
./phagex assembly -1 R1.fq -2 R2.fq -i phage001 -o result

# Only annotation (input: FASTA)
./phagex annotation -i genome.fa -o result

# Generate batch processing scripts
./phagex generate -l samples.txt -o batch_result -t 16
```

**Configuration**: Uses `phagex.json` which defines absolute paths to:
- Tools: fastp, seqtk, seqkit, spades, checkv, prodigal, blastp, hmmscan, etc.
- Databases: checkv-db, nr_phage, uniref, uniprotkb, pfam

### dcp (DCS Cloud Tool)
Batch job submission for DCS Cloud (华大序风云平台). Only works in DCS Cloud environment.

```bash
# Submit batch jobs
./dcp sub scripts.txt -c 4 -m 32g --tag batch1

# Check job status
./dcp stat [tag]
./dcp list
```

### phold-circos.py
Generates circular genome maps from phold output GenBank files.

```bash
python phold-circos.py -i phold.gbk -o output.pdf --dpi 300
```

## Important Notes

1. **Language**: Primary documentation is in Chinese. Script help text is also in Chinese.

2. **Bioinformatics Focus**: Scripts are specialized for phage (噬菌体) genome analysis and metagenomics workflows.

3. **External Dependencies**: Scripts rely on conda/mamba environments and external tools (not vendored). The `phagex.json` contains absolute paths to user-specific installations that will need updating for different environments.

4. **Cluster/Cloud Specific**: `dcp` and `autoqsub` are designed for specific HPC environments (DCS Cloud and qsub-based clusters respectively).

5. **No Build System**: This is not a buildable software project. Scripts are executed directly. Python scripts use standard library + common packages (no requirements.txt).

## Documentation Reference

The README.md contains detailed guides for:
- Linux command-line basics (ssh, vim, file operations, awk, sed, etc.)
- Bioinformatics tool installation (conda, mamba, BWA, BLAST, SPAdes, etc.)
- Metagenomics analysis workflows
- Bash environment configuration (.bashrc examples)

When modifying scripts or documentation, maintain the existing Chinese language for consistency.
