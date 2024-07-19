from Bio import Entrez
import os
import re
import time
import random

Entrez.email = "zoranlee0118@gmail.com"
Entrez.api_key = "c08806b6f645fda8211eb5afa5950b208c08"

with open('C:\\Users\\Zoran\\OneDrive\\05_Bioinfo&Code\\Entrez\\genus_list.txt', 'r') as f:
    for GENUS_ID in f:
        GENUS_ID = GENUS_ID.strip()
        print(f"Searching for {GENUS_ID}")
        search_results = Entrez.read(Entrez.esearch(db="nucleotide", term=f"{GENUS_ID}[title] AND phage[title] AND viruses[filter] AND isolation[All fileds]", idtype="acc", usehistory="y"))

        count = int(search_results["Count"])
        batch_size = 10
    
        filename = f"C:\\Users\\Zoran\\OneDrive\\05_Bioinfo&Code\\Entrez\\gut_review\\{GENUS_ID}.txt"
        out_handle = open(filename, "w")
        for start in range(0, count, batch_size):
            end = min(count, start+batch_size)
            print("Going to download record %i to %i" % (start+1, end))
            fetch_handle = Entrez.efetch(db="nucleotide", rettype="gb", retmode="text",retstart=start, retmax=batch_size,webenv=search_results["WebEnv"], query_key=search_results["QueryKey"])
            data = fetch_handle.read()
            fetch_handle.close()
            data = re.sub(r'CDS.*?//', '', data, flags=re.DOTALL)
            out_handle.write(data)
            time.sleep(random.randint(1, 3))
        out_handle.close()
        print("\n")
