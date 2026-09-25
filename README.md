# 1D Cutting Stock Problem (CSP)

A **Mixed Integer Linear Programming (MILP)** model in **R** for the **1D Cutting Stock Problem**, built with the [`ompr`](https://dirkschumacher.github.io/ompr/) modeling framework and solved via the **SYMPHONY** solver (through `ROI`).

## Overview

The 1D Cutting Stock Problem (CSP) is a classic combinatorial optimization problem in Operations Research. A set of items of different lengths must be cut from standard raw stock pieces of fixed length. The goal is to **satisfy the demand for each item type while using the minimum number of raw stocks**.

The model adopts a **pattern-based formulation**: rather than deciding individual cuts one at a time, all feasible cutting configurations (patterns) are enumerated in advance. Each pattern specifies how many pieces of each item type can be cut from a single raw stock. The decision variables then represent how many times each pattern is applied.

This formulation is widely used in manufacturing (paper, steel, glass, wood) wherever long raw materials must be cut into shorter pieces with minimum waste.

## Repository Contents

| File | Description |
|---|---|
| `1D Cutting Stock.R` | R script implementing and solving the CSP instance |
| `1D Cutting Stock.pdf` | Mathematical formulation of the problem |

## Mathematical Formulation

### Sets

- $I$ = set of item types (index $i$)
- $J$ = set of feasible cutting patterns (index $j$)

### Parameters

- $L$ = length of the standard raw stock
- $l_i$ = length of item type $i$; $\forall\, i \in I$
- $d_i$ = demand (number of pieces required) of item type $i$; $\forall\, i \in I$
- $a_{ij}$ = number of pieces of item type $i$ cut in pattern $j$; $\forall\, i \in I,\ j \in J$
- $w_j$ = waste of pattern $j$ (unused length): $w_j = L - \sum_{i \in I} l_i \cdot a_{ij}$; $\forall\, j \in J$

### Variable

- $x_j$ = number of raw stocks cut according to pattern $j$; $x_j \in \mathbb{Z}^+$, $\forall\, j \in J$

### Objective Function

**(1)** — Minimize total number of raw stocks used

$$
\displaystyle \min \sum_{j \in J} x_j
$$

### Constraints

**(2)** — Demand satisfaction: the total pieces of item $i$ cut across all patterns must meet or exceed its demand

$$
\displaystyle \sum_{j \in J} a_{ij} \cdot x_j \ge d_i \qquad \forall\, i \in I
$$

**(3)** — Non-negative integer variables

$$
x_j \in \mathbb{Z}^+ \qquad \forall\, j \in J
$$

> **Note on the pattern-based approach:** The constraint (2) uses $\ge$ rather than $=$ because cutting slightly more than demanded is acceptable (overproduction due to indivisible patterns is a natural feature of the CSP). The pattern matrix $A$ encodes the combinatorial structure of the problem — each column represents a different feasible way to cut a raw stock — so the model only needs to count how many times each pattern is used.

> **Relation to Bin Packing:** The CSP and BPP share the same minimization structure (minimize number of stocks / bins), but differ in their decision unit: the BPP assigns individual items to bins, while the CSP works with pre-enumerated patterns that group multiple cuts together. The CSP also allows general integer variables (not binary) and demands $\ge$ rather than $=$.

A copy of this formulation is also available as a standalone PDF in this repository.

## Example Instance

The script uses a hardcoded instance with **5 item types** and **20 cutting patterns** (columns of matrix $A$):

**Item demands:**

| Item $i$ | Demand $d_i$ |
|:---:|---:|
| 1 | 50 |
| 2 | 30 |
| 3 | 40 |
| 4 | 42 |
| 5 | 20 |

**Cutting pattern matrix $A$** (rows = items, columns = patterns):

$$
A = \begin{pmatrix}
1 & 0 & 0 & 1 & 1 & 0 & 0 & 0 & 0 & 0 & 1 & 0 & 0 & 0 & 1 & 0 & 0 & 0 & 2 & 0 \\
1 & 0 & 2 & 0 & 0 & 0 & 1 & 1 & 0 & 0 & 0 & 1 & 0 & 0 & 0 & 1 & 0 & 0 & 0 & 0 \\
0 & 2 & 0 & 1 & 0 & 0 & 1 & 0 & 1 & 2 & 0 & 0 & 1 & 0 & 0 & 0 & 1 & 0 & 0 & 0 \\
0 & 1 & 0 & 0 & 2 & 0 & 0 & 2 & 2 & 0 & 1 & 1 & 1 & 3 & 0 & 0 & 0 & 2 & 0 & 1 \\
1 & 0 & 1 & 1 & 0 & 4 & 1 & 0 & 0 & 1 & 1 & 1 & 1 & 0 & 2 & 2 & 2 & 1 & 0 & 2
\end{pmatrix}
$$

Each column $j$ defines a feasible way to cut one raw stock: entry $a_{ij}$ is the number of pieces of item $i$ produced by that cut. For example, pattern 6 (column 6, 0-indexed) produces 4 pieces of item 5 and nothing else, while pattern 1 produces 2 pieces of item 3 and 1 piece of item 4.

## Requirements

```r
install.packages(c("lpSolve", "dplyr", "ROI", "ROI.plugin.symphony", "ompr", "ompr.roi"))
```

## Usage

1. Clone or download this repository.
2. Open `1D Cutting Stock.R` in R or RStudio.
3. Update the `setwd()` path at the top of the script to match your local directory.
4. Run the script. It will:
   - Build and solve the MILP model using `ompr` and SYMPHONY
   - Print the optimal number of raw stocks used (objective value)
   - Print all active pattern variables $x[j] > 0$, showing which patterns are applied and how many times

## Output

The script prints:

- **Objective value** — the minimum total number of raw stocks required
- **$x[j]$ variables** — for each pattern used at least once, its index and the number of times it is applied
