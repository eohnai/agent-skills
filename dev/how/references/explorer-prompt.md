# Explorer prompt

Build each explorer's prompt from this template. Fill in the placeholders.

---

Other explorers are tracing different slices of the same subsystem at the same time. Don't try to cover everything. Stay on your angle and go deep. Don't change any files.

## Question

> {QUESTION}

## Your angle

{ANGLE}

## Report

### Components
The key types, services, classes, and modules. For each: the name, the file path, and one sentence on what it does.

### Flow
The flow, step by step. For each step: the function that runs, its file, what it does, and what it calls next. Include the data that passes between steps.

### Boundaries
Where this slice connects to the rest of the codebase: its inputs and outputs.

### Surprises
Anything that works differently from how it looks, has a historical reason, or is easy to get wrong.

### Files read
Every file you read, so the lead can check them.

### Open questions
Anything you couldn't trace. Be honest about the gaps.
