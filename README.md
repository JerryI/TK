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

## Manual

### What and Why?

Extracting material parameters from optical data is a challenging task. In slab-like samples, the incoming pulse reflects within the material, resulting in the output spectrum being convolved with Fabry–Perot resonances. This is both a benefit and a challenge: while it complicates deconvolution, it also provides additional information about the sample thickness and helps compensate for aperture mismatches between the reference and the sample — a common issue in transmission experiments.

This tool was developed to automate much of this process for Time-Domain experiments.

**Key Features:**

- **File name decoding**: Automatically matches reference and sample pairs using an ElMO neural network.
- **Batch processing**: Computes transmission data for all selected files automatically.
- **Assisted phase unwrapping**: Optical phase is typically wrapped between -π and π, which is not usable for extracting optical parameters. This tool can automatically unwrap the phase and allows manual correction of excitonic positions (usually where phase breaks occur), if needed.
- **Accurate absorption coefficient extraction & Fabry–Perot deconvolution**: Offers an interactive process to iteratively correct thickness and gain, solving Fresnel equations and extracting refractive index \( n \), extinction coefficient \( k \), or complex \( \tilde{n} \).
- **Summary reporting**: Stacks and plots spectra (automatically sorted using a neural network) of optical conductivity, transmission, and absorption. Metadata is saved in the experiment folder.
- **File-based workflow**: Functions as a file browser. It recognizes processed spectra within a folder, displays previews, supports data modification, and works entirely offline by storing a `._TK_store` file in each experiment folder.

---

### Input Data Format

TeraKitchen works with ASCII-like files, stored separately for the sample and its corresponding reference in the time domain:

```
MySample_4K_0T.csv
MySample_4K_0T_ref.csv
...
```

Each file should contain two columns:

```
time axis; y-axis
```

You can select the appropriate units for the time axis in the import wizard window.



## Example Data
### ATR470

### ATR384


## Technology stack

- Wolfram Engine
- WLJS Notebook
- JerryI/TDSTools

## License
MIT

excluding *ELMo Contextual Word Representations Trained on 1B Word Benchmark*  