---
title: "Math is Really Cool"
date: "2024-02-07"
tags: ["mathematics", "number theory", "geometry"]
params:
  math: true
---
I’ve recently been reading a book. It’s about number theory and the title is “A Friendly Introduction to Number Theory” by Joseph H. Silverman. I have only begun reading the first few pages and I already like mathematics more than ever before!

I feel my background is crucial for others to understand my circumstances: I am from a third world country, and my school life was seldom great, but I guess that’s true for most people considering the rotten high schools of today. Mathematics, to me always felt like something very logical, but figuring out the logical resultant was never fun to me, because I couldn’t connect the dots myself; I could only ever know how and why I would connect the dots the way the textbook intended. My school never tried to help me with this either.

After ten years of such schooling, I had some ideas on how to tackle this problem: best of them one was to fully understand the fundamentals. So I tried reading my textbooks from former school years, but it hardly _really_ helped… I was scoring better on papers, but I never truly found it fun doing it. It was slightly more exciting, sure, but not very fun. I was demotivated by this; I then conjectured that mathematics just isn’t my thing and I should embrace the thought.

Then I started embracing my circum- No… I started _pretending_ to be embracing my circumstances: I don’t think I ever just blindly accepted that I sucked at mathematics; there were parts of me that were yearning to make it fun and then see how I performed. Subsequently, I started reading external books, eventually grabbed one on number theory — the book I discussed about in the first paragraph.

This book had some cool ways of visualizing mathematical concepts. I was never taught triangular numbers in my school textbooks but I found out about it from this book. Triangular numbers are numbers that can form a triangle if you assume the triangular number $x$ as that number of cells. Even if I had heard about square numbers, my school textbooks only ever described it algebraically. This book manifested in me new ways of looking at square and triangular numbers, they are geometrically just box and triangles. I know, I know, basic stuff for geometry people, but my knowledge was akin to kindergarten boys until yesterday’s breakthrough via this book.

So, four geometrically is:

```
. .
. .
```

… And three geometrically is:

```
 .
. .
```

Two years ago, I first learned about Gauss’ formula, 
$$
\frac{n \cdot (n+1)}{2}
$$
From my school’s textbook. Their explanation was based on arithmetic progression. However this book took a wonderful approach to explaining it. It was a very simple and meaningful geometric approach. If you calculate the first few triangular numbers, you get $1, 3, 6, 9$ and so on… If you try to find a pattern, you end up with $1 + 2 = 3$, $1 + 2 + 3 = 6$, and so on.

I am in awe whenever people make impressive innovations merely from simple experiments. From wagons, like five thousand years ago, to the first bicycle two centuries ago... Maybe we should experiment with what I have thus far discussed too! Um, what if we join two triangles together? Of course, there are various ways to pair two triangles together; some of them look like squares, however. The progression of cells from triangular numbers visually looks equilateral; maybe if we try hard enough, we can find triangular numbers that are also squares...

So,

```
.
. .
```

And,

```
. .
  .
```

If we pair them together, we get,

```
. .. 
.. .
```

Something like that. ASCII art is limited, so that’s the best I could do. Sorry about that!

Mathematically, it is, $(1 + 2) + (1 + 2) = 6$, then $(1 + 2 + 3) + (1 + 2 + 3) = 12$, and so on…

If we want to create a square out of two triangles, pairing the two triangles won’t be a square unless we overlap the two. Now, what if we add a diagonal here?

```
. . .
. . .
. . .
```

If we add a diagonal that is one cell larger than largest side of the two triangles, we get a square. It consists of:

```
.
. .
```
```
  . .
    .
```

```
.
 .
  .
```

Mathematically, it is $(1 + 2) + (1 + 2) + 3 = 9$, $(1 + 2 + 3) + (1 + 2 + 3) + 4 = 16$, and so on... We got squares of three and four. Adding a diagonal $(n + 1)$ cells long than the largest side with $n$ cells of two congruent triangles makes a square. We can derive an equation from this information:
$$
(1 + 2 + 3 + \ldots + (n - 1)) \times 2 + n = n^2
$$
Or,
$$
(1 + 2 + 3 + \ldots + n) \times 2 + (n + 1) = (n + 1)^2
$$
If we focus on, 
$$
(1 + 2 + 3 + \ldots + n) \times 2 + (n + 1) = (n + 1)^2
$$
We get to see $(1 + 2 + 3 + ... + n)$. That’s Gauss’ formula there, right? We may derive that formula if we solve for that:
$$
(1 + 2 + 3 + \ldots + n) \times 2 + (n + 1) = (n + 1)^2 
\\\\~\\\\
(1 + 2 + 3 + \ldots + n) \times 2 = (n + 1)^2 - (n + 1)
\\\\~\\\\
(1 + 2 + 3 + \ldots + n) = \frac{(n + 1)^2 - (n + 1)}{2}
$$

If $n = 5$, we should get fifteen as $1 + 2 + 3 + 4 + 5 = 15$.

$$
\frac{(5 + 1)^2 - (5 + 1)}{2} = \frac{6^2 - 6}{2} = \frac{36 - 6}{2} = \frac{30}{2} = 15.
$$

Cool! If we simplify our equation, we will get, 
$$
\frac{{(n + 1)^2 - (n + 1)}}{2}
\\\\~\\\\
= \frac{{(n + 1)^2 - n - 1}}{2}
\\\\~\\\\
= \frac{{n^2 + 1 + 2n - n - 1}}{2}
\\\\~\\\\
= \frac{{n^2 + n}}{2}
\\\\~\\\\
= \frac{{n(n + 1)}}{2}
$$
On one side.

This explanation was so fun! I could connect all the dots!

