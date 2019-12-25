from collections import defaultdict, Counter
from ncls import NCLS
import numpy as np
import sys
import re

def getChromosome(str):
    if str == "*" or str[3:] == 'X':
        return -1
    try:
        return int(str[3:])
    except:
        return -1

def generate_empty_list():
    list = []
    list.append([])
    list.append([])
    return list

def handle_gtf(file):
    frequency_trees = defaultdict(generate_empty_list)
    print("$$$$$$$$$$$$$$$$$$")
    print(file)
    print("$$$$$$$$$$$$$$$$$$")
    gtf = open(file, 'r')
    for line in gtf:
        line = line.split('\t')
        try:
            chr = int(line[0])
            try:
                if (line[2] != 'transcript'):
                    frequency_trees[chr][0].append(int(line[3]))
                    frequency_trees[chr][1].append(int(line[4]))
            except:
                print("This shouldn't happen - GTF handleing is wrong")
        except:
            pass
    for key in frequency_trees.keys():
        frequency_trees[key] = NCLS(np.array(frequency_trees[key][0]), np.array(frequency_trees[key][1]), np.array(frequency_trees[key][0]))
    return frequency_trees

def parseString(txt, frequency_tree):
    spliter = re.compile('\n+')
    readnumber = re.compile('[r]+\d+')
    line_spliter = re.compile('\t+')
    colon_spliter = re.compile(':')
    forward_reads = 0
    reverse_reads = 0
    unmatched_reads = 0
    read_positions = defaultdict(list)
    position_differences = []
    position_differences_stdv_list = []
    total_position_diffs = []
    read_lengths_count = 0
    read_lengths_total = 0
    read_frequency = 0
    read_lengths_average = 0
    num_chromosomes = 0
    num_a = 0
    num_c = 0
    num_g = 0
    num_t = 0

    lines = spliter.split(txt)
    for i in range(len(lines) - 1):
        subline = line_spliter.split(lines[i])
        if (int(subline[1]) & 4 == 4):
            unmatched_reads += 1
        elif (int(subline[1]) & 16 == 16):
            reverse_reads += 1
        else:
            forward_reads += 1
        read = subline[9]
        read_lengths_count += 1
        read_lengths_total += len(read)
        bases_count = Counter(read)
        num_a += bases_count["A"]
        num_c += bases_count["C"]
        num_g += bases_count["G"]
        num_t += bases_count["T"]
        chromosome = getChromosome(subline[2])
        if chromosome != -1:
            read_positions[chromosome].append(int(subline[3]))
    if read_lengths_count != 0:
        read_lengths_average = read_lengths_total / read_lengths_count
    if (forward_reads + reverse_reads + unmatched_reads) != 0:
        read_frequency = (forward_reads + reverse_reads) / (forward_reads + reverse_reads + unmatched_reads)

    gene_annotation_match = 0
    gene_annotation_total = 0
    gene_annotation_percent = 0
    for key in read_positions.keys():
        for position in read_positions[key]:
            #TODO there is for sure a better way to do this than with a break
            for _ in frequency_tree[key].find_overlap(position, position):
                gene_annotation_match += 1
                break
            gene_annotation_total += 1
    if gene_annotation_total != 0:
        gene_annotation_percent = gene_annotation_match / gene_annotation_total

    for _, position_list in read_positions.items():
        position_list.sort()
        num_chromosomes += 1
        for i in range(len(position_list) - 1):
            position_differences.append(position_list[i + 1] - position_list[i])
    try:
        std_of_pos_diff = np.std(position_differences)
        mean_of_pos_diffs = np.nanmean(position_differences)
        max_position_difference = np.amax(position_differences)
        min_position_difference = np.amin(position_differences)
    except:
        return None
    return ["Your Accesion", gene_annotation_percent, read_lengths_average, read_frequency, std_of_pos_diff, mean_of_pos_diffs, num_chromosomes, max_position_difference, min_position_difference, num_a/ read_lengths_total, num_c/ read_lengths_total, num_g / read_lengths_total, num_t / read_lengths_total]

def main(str, file):
    return parseString(str, handle_gtf(file))
