import re
readnumber = re.compile('[r]+\d+')
line_spliter = re.compile('\t+')
colon_spliter = re.compile(':')

def parse(filename):
    forward_reads = 0
    reverse_reads = 0
    unmatched_reads = 0
    read_quality = [[]]
    match_scores = []

    #TODO throw an error/ warning if the readSize is greater than the number
    #of lines in the file.
    f = open(filename)
    #Splitting everyline into its own place in the arry
    lines = f.readlines()
    #Itterating though everyline
    for i in range(3, len(lines)):
        get_match_score = True
        #Splitting the lines into whitespace
        subline = line_spliter.split(lines[i])

        if (subline[1] == '0'):
            forward_reads += 1
        elif (subline[1] =='16'):
            reverse_reads += 1
        else:
            unmatched_reads += 1
            get_match_score = False

        for j in range(len(subline[10])):
            while(len(read_quality) < len(subline[10])):
                read_quality.append([])
            read_quality[j].append(subline[10][j])

        if (get_match_score):
            match_scores.append(int(colon_spliter.split(subline[11])[2]))
    return (forward_reads, reverse_reads, unmatched_reads, read_quality, match_scores)
