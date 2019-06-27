WordNet

Introduction
------------
[WordNet][wordnet home] is a semantic lexicon for the English language that is used extensively by computational linguists and cognitive scientists. WordNet groups words into sets of synonyms called *synsets* and describes semantic relationships between them. Relevant to this project is the *is-a* relationship, which connects a *hyponym* (more specific synset) to a *hypernym* (more general synset). For example, a plant organ is a hypernym to plant root and plant root is a hypernym to carrot.

Structure of WordNet Graph
--------------------------
In order to perform operations on WordNet, you will construct your own representation of hypernym relationships using the provided graph implementation. Each vertex `v` is a non-negative integer representing a synset id, and each directed edge `v->w` represents `w` as a hypernym of `v`. The graph is directed and acyclic (DAG), though not necessarily a tree since each synset can have several hypernyms. A small subset of the WordNet graph is illustrated below.  
![Sample WordNet Graph][sample graph]

Input File Formats
------------------
The WordNet is represented by two files which must each be formed as described below in order to be valid. A major part of this project will be to process and load from these supplied input files.

### Synsets File
The synsets file is a list of all of the synsets in WordNet (i.e. the vertices of the graph above). A synset is a list of nouns that share the same meaning. Each line of a valid synsets file consists of two fields:
- **Synset id**: A non-negative integer identifying the synset.
- **Synset**: A comma-delimited list of one or more nouns that belong to the synset. Nouns are made up of letters (uppercase and lowercase), numbers, underscores, dashes, periods, apostrophes, and forward slashes. These criteria will always define valid nouns wherever valid nouns are referenced in this document.

**Note**: A noun can appear in more than one synset. A noun will appear once for each meaning the noun has. For example, all of the following synsets contain the noun "word", but with different meanings.
```
id: 37559 synset: discussion,give-and-take,word
id: 50266 synset: news,intelligence,tidings,word
id: 60429 synset: parole,word,word_of_honor
id: 60430 synset: password,watchword,word,parole,countersign
```

### Hypernyms File
The hypernyms file contains the hypernym relationships between synsets. Each line of a valid hypernyms file contains two fields: 
- **Synset id**: A non-negative integer identifying the synset these edges originate from.
- **Hypernym ids**: A comma-delimited list of one or more non-negative integers representing synsets that edges will go to.

Each line of the file represents a set of edges from a synset to its hypernyms. For example, the line
```
from: 171 to: 22798,57458
```
means that the synset 171 ("Actified") has 2 hypernyms: 22798 ("antihistamine") and 57458 ("nasal_decongestant"), meaning that Actified is both an antihistamine and a nasal decongestant. The synsets are obtained from lines in the synsets file with the corresponding synset ids.

**Note**: A synset's hypernyms are not restricted to being listed on a single line. They may be split among multiple lines. For example, the hypernyms from the example above may also be represented as follows:
```
from: 171 to: 22798
from: 171 to: 57458
```