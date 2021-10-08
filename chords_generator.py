# chords sequence generator

chords = []

with open('pseudochords base.txt', 'r') as f1:
    for line in f1.readlines():
        chords.append(line.rstrip())

print(chords)


# with open('res.txt', 'w'):
    
