# the SunTiger
### A search engine developed as a week project at Makers Academy

A search engine built from scratch, only using the gem Nokogiri to parse the web pages. A search engine is something all of us know, use and love very dearly (how many times have you Google'd something today?), but not many of us understand the mechanisms that make the engine tick. Or search, in this case.

#### But how does a seach engine work?
To get a better understanding, we have decided to built one ourselves. A search engine mostly exists out of four components:
1) **the Crawler**: also known as a spider, which 'crawls' the web. It takes in a list of seeds (initial web pages the search engine will look through), and saves all the links, text, headers and other metadata it can find of each seed. For each link on the seed, it will click on that link and look through all the information it can find on that link. 
[image crawler]
Momentarily, the search engine only saves the links - a next step will be to store these links in the seedfile, and run the crawler again.

2) **the Indexer**: the indexer splits all the information in digestible chunks, in words to be exact, and counts how many times each word is used within each seed. These are also categorised in where they've been found within the seed: one can imagine that finding a word within the url, or in the description, is more valuable than finding it somewhere in a small paragraph. In our search engine, these words are saved within a hash. Each attribute (urls, description, regular text) is a key, and the value is another hash of all words found and their count value.

3) **the Ranker**: the ranker gives a final value to each seed, given a (set of) keyword(s). Depending on how often the keyword is found in the seed, and where. Each seed corresponds to one ranker; the seed with the highest ranking value will be the most compatible seed and displayed at the top.

4) **the Query**: the query is the keyword or words that the user puts in, which will be taken into account in the ranker. Momentarily, only one keyword can be used in our search engine.

## How to Run
- clone this repo
- `ruby lib/interface`
- input keyword

See [this video](https://vimeo.com/227817356) as an example.

## Tech Stack

## Objects
#### Crawler: 
- initialises with array of seeds
- fetches data from each seed url
	- all the urls on the page
	- keywords provided in the head of the page (given by tag
	  'meta')
	- description provided in the head of the page (given by tag
	  'meta')
	- all headers on the page (h1 unto h6)
	- the full text on a page, as a raw string without
	  punctuation (given by tag 'p')
- saves all data in a CSV file. Each row in the file is a new
  seed

#### Indexer:
- For each seed, removes all the stopwords from data provided
- Stems the words (e.g. groups together words such as 'fish',
  'fishes', 'fishing', etc.)
- Counts amount of time each word is being used from each data
  attribute in a hash [PROVIDE EXAMPLE]
- includes the index of the seed, to correlate with the data
  in the CSV

#### Ranker:
- Calculates a score when a query word is provided
- Takes in hash provided by the indexer, plus the query
- Calculates final score by multiplying the amount of times a
  word is used by a value dependent on where the word is
found.
	- Multiplier breakdown:
	```
	urls:         5x
	keywords:     4x
	description:  3x
	headers:      2x
	text:         1x
	```
	- Example: query word = "spider". Used in:
		- urls: 0
		- keywords: 2
		- description: 1
		- headers: 2
		- text: 6
		- total score: (2 x 4) + (1 x 3) + (2 x 2) + (6 x 1) = 21

#### Interface
- Interacts with the user
- User can give a keyword to search
- for all seeds a ranker is created
	- each ranker calculates the total score relative to the
	  query
- all ranks are placed in an array and sorted by score
- All seed urls are printed in the proposed sorting, highest
  rank at the top


## User Stories
#### EPIC
```
As a Person,
So I can expand my knowledge,
I would like to search some websites
```

#### Breakdown
```
As a Person,
So I can search for a specific topic,
I can type in some keywords
```

```
As a Person,
So I can choose the right website to visit,
I want the options to be displayed
```

```
As a Person,
So I can choose the most relevant website,
I want the options to be ranked
```

```
As a Person,
So I have the right information,
I want the search engine to look for specific matching data on a webpage
```

```
As a Maintainer,
So I can save storage,
I want to stem the raw texts from webpages before indexing
```

```
As a Maintainer,
So I have control over my crawler,
I want the possibility to add URLs to the seed manually
```

