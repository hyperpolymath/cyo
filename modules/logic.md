# Adventure: Logic & Neuro-Symbolic (NeSy)

Traditional programming is imperative (how to do it). Logic programming is declarative (what the result should look like). Neuro-Symbolic AI (NeSy) is the bridge between the logic of the mind and the pattern-matching of the brain.

## Level 1: The Foundation (Low Effort) — Datalog / Prolog
**The Friction:** Relational data is hard to query with loops and if-statements. SQL is limited for complex recursive relationships.
**The Fix:** Use **[Datalog](https://datalog.org/)** or **Prolog**.
- **Impact:** Powerful recursive queries. Used in modern databases (Datomic, Cozo) and static analysis tools.

## Level 2: The Embedded Logic (Medium Effort) — miniKanren
**The Friction:** You want logic programming but don't want to leave your host language (Python, Rust, Clojure).
**The Fix:** Use **[miniKanren](http://minikanren.org/)**.
- **Implementations:** 
    - **Clojure:** `core.logic`
    - **Python:** `kanren`
    - **Rust:** `canrun`
- **Impact:** A "relational" DSL that lives inside your code. It doesn't just "run" functions; it "solves" them in both directions.

## Level 3: The Deep Bridge (High Effort) — NeSy Frameworks
**The Friction:** Neural networks are "black boxes" that struggle with logic. Symbolic logic is "brittle" and struggles with messy real-world data (images, sound).
**The Fix:** Use Neuro-Symbolic frameworks like **[DeepProbLog](https://github.com/ML-Research/deepproblog)** or **Scallop**.
- **Impact:** Allows you to train neural networks that output logical symbols, which are then processed by a rigorous logic engine.

## Level 4: The Diplomat (Future-Proof) — Neural-Guided Search
**The Friction:** Pure symbolic search (like miniKanren) suffers from "state space explosion"—it tries too many useless paths.
**The Strategy:** Use a **Neural Guide** for a **Symbolic Engine**.
- **The Workflow:**
    1.  **Search:** Use **miniKanren** (in Rust or C++) to define the valid search space.
    2.  **Heuristic:** Use a **Neural Network** (in Python/PyTorch) to predict which branch miniKanren should explore first.
- **Impact:** You get the **Provable Correctness** of symbolic logic with the **Intelligence/Intuition** of neural networks.
- **Projects:** Check out **[neuralkanren](https://github.com/xuexue/neuralkanren)**.
