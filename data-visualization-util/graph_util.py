from parser import parse
# import plotly.plotly as py
# import plotly
# import plotly.graph_objs as go

def matched_vs_unmatched_pie_chart(forward_reads, reverse_reads, unmatched_reads):
    match_chart_labels = ['Forward Reads(Matched)', 'Reverse Reads (Matched)', 'Unmatched Reads']
    match_chart_values = [forward_reads, reverse_reads, unmatched_reads]
    return (match_chart_labels, match_chart_values)
