# Terakitchen
*University of Augsburg, EPV*
*Developer: kirill.vasin@uni-a.de*

![](./imgs/landing-back.png)

A WLJS Notebook app for managing and processing optical time-domain transmission spectra

## Key-features

- __works with normal files, autosaves meta-data__
- __automatic reference-sample pairs matching__ using ELMo network
- automatic sorting using a local neural network
- __semiautomated advanced material parameters extraction__
- __Fabry-Pérot deconvolution (GPU accelerated)__
- __interactive phase unwrapping__
- __automated reports__
- easy exports to ASCII format

## How to run
1. Install [WLJS Notebook](https://jerryi.github.io/wljs-docs/)
2. Download this repository
3. Start `TK.wlw`

## Screenshots

Preview on the selected project folder

![](./imgs/dark-2.png)

Automatic reports

![](./imgs/summary-1.png)

Assisted phase uwrapping

![](./imgs/phase-2.png)

High-precision material parameters extraction

![](./imgs/material-2.png)

File names matcher

![](./imgs/names-1.png)


## Technology stack

- Wolfram Engine
- WLJS Notebook
- JerryI/TDSTools

## License
MIT

excluding *ELMo Contextual Word Representations Trained on 1B Word Benchmark*  