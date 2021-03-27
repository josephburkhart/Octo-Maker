# Octo-Maker
Octo-Maker is a program for automatically creating truncated [octopods](https://doi.org/10.1021/nl200824p) and [stella octangulas](https://mathworld.wolfram.com/StellaOctangula.html) with specified dimensions in Sketchup.

% picture of octopod, picture of stella octangula

**Compatibility:**
Sketchup 2017-2021

## Background
Octopods and stella octangulas are concave geometric solids with octahedral (**O<sub>h</sub>**) symmetry. Both shapes are readily accessible in seed-mediated nanoparticle synthesis [[1](https://doi.org/10.1021/ja308456w)]. For example, octopods can be created from cubic seeds when metal atoms are deposited only along the vertices of the cube (i.e., crystal growth occurs in the [111] direction) [[2](https://doi.org/10.1021/ja308456w)]. Stella octangulas can be created from octahedral seeds when metal atoms are deposited only on the faces of the octahedron (growth occurs in the [111] direction). When the branches of octopods and stella octangulas are flattened or rounded, rather ten sharp, they are said to be "truncated."

Both geometries are completely constrained by 3 dimensions (see images below):
- face diagonal (FD - distance between the centers of branch tips which are diagonally adjacent)
- branch width (BW - distance between two neighboring vertices that each connec to 4 branches) 
- tip width (TW - distance across the face of each branch tip, 0 if the branch is sharp)

% picture of the dimensions

Often, octopodal nanoparticles are "capped" with an additional metal on their branch tips. Thus, the user can set an additional parameter, "tip depth" (TD) to separate a portion of the branch from the model. TD is the distance from the tip face along the [111] direction that the user wishes to separate. For example:

% pictures of TD 0, 10, 20

## Instructions
1. Download `Octo-Maker.rb`
2. Open Sketchup and navigate to the Extension Warehouse (Windows > Extension Warehouse). 
3. Install the plugin [STL Import and Export](https://github.com/SketchUp/sketchup-stl), which will be used to export the final model.
4. Optional but recommended: install the plugin [Ruby Code Editor](https://alexschreyer.net/projects/sketchup-ruby-code-editor/)
5. To run the code, either:
    - In Sketchup's code editor window (Window > Ruby Code Editor > Ruby Code Editor), open `Octo-Maker.rb` (File > Open) and then run the file (Run > Run Code)
    - Copy the contents of `Octo-Maker.rb`, paste it into Sketchup's ruby console (Window > Ruby Console), and hit <kbd>Enter</kbd>.
6. Choose the directory where the model will be saved
7. Provide inputs according to the desired shape and dimensions
8. Click "OK"

## References
1 https://doi.org/10.1039/C8NR07233G
2 https://doi.org/10.1021/ja308456w
