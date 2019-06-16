def phred33_to_q(qual):
  #Turn Phred+33 ASCII-encoded quality into Phred-scaled integer
  return ord(qual)-33

def q_to_p(Q):
  #Turn Phred-scaled integer into error probability
  return 10.0 ** (-0.1 * Q)

def read_quality_converter(read_quality):
    for i in range(len(read_quality)):
        for j in range(len(read_quality[i])):
            #Converting the read quality data to probabilities
            read_quality[i][j] = phred33_to_q(read_quality[i][j])
            
def make_data_for_box_plot(read_quality):
    data = [[]]
    for i in range(len(read_quality)):
        data.append(read_quality[i])
    return data
