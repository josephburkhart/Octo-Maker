# This program makes an octopod or a stella otangula that meets the user's input parameters (face diagonal, branch width, tip width). This model is then exported as an STL file to a specified directory.

## --- USER INPUT
prompts = ["Face Diagonal (nm)", "Branch Width (nm)", "Tip Width (nm):","Shape (0 - octopod, 1 - stella octangula)","Do you want tips saved separately? (0 = yes, 1 = no)","Tip Depth"]
defaults = ["face diagonal", "branch width", "tip width"]
inputs = UI.inputbox(prompts, defaults, "Particle Dimensions")
directory = UI.select_directory(title: "Choose Model Destination") #model will be saved to this directory
puts directory


## --- GLOBAL VARIABLES
mod = Sketchup.active_model # Open model
ent = mod.entities          # All entities in model
sel = mod.selection         # Current selection

f_d = inputs[0].to_l
br_w = inputs[1].to_l
t_w = inputs[2].to_l

shapename = "Octopod_" if inputs[3].to_f == 0
shapename = "StellaOctangula_" if inputs[3].to_f == 1
dimensions = "FD#{f_d}_BrW#{br_w}_TW#{t_w}"


## --- CHECK FOR UNWANTED INPUTS
inputs.each{|input|
  if input.to_f < 0
    puts "Error: shape dimensions must be greater than 0"
    abort
  end
}
if inputs[3].to_f != 0 && inputs[3].to_f != 1
  puts "Error: question 4 must be answered with either 0 or 1"
  abort
end
if inputs[4].to_f != 0 && inputs[4].to_f != 1
  puts "Error: question 5 must be answered with either 0 or 1"
  abort
end


## --- CREATE OCTOPOD
if inputs[3].to_f == 0

  # CREATE BASE POINTS
  base_pos = (br_w*(2**0.5) / 2)
  base_points = [
    Geom::Point3d.new(0,base_pos,0),
    Geom::Point3d.new(base_pos,base_pos,0),
    Geom::Point3d.new(base_pos,0,0),
    Geom::Point3d.new(base_pos,0,base_pos),
    Geom::Point3d.new(0,0,base_pos),
    Geom::Point3d.new(0,base_pos,base_pos)
  ]

  # CREATE TIP POINTS (Note: the formulas for px, pz, sx, sz were determined by Joseph Burkhart and IU Mathematics PhD candidates Insung Park and Homin Lee - see Joseph Burkhart's lab notebook for derivation)
  px = -(br_w*(3*br_w - 6*f_d + t_w*(3**0.5)) + ((br_w**2)*(9*(br_w**2) - 2*br_w*(9*f_d + t_w*(3**0.5)) + 3*(3*(f_d**2) + (t_w**2))))**0.5) / (6*br_w)
  sx = (br_w*(-3*br_w + 6*f_d + t_w*(3**0.5)) - ((br_w**2)*(9*(br_w**2) - 18*br_w*f_d + 9*(f_d**2) - 2*(3**0.5)*br_w*t_w + 3*(t_w**2)))**0.5) / (6*br_w)

  pz = (br_w*(6*br_w - 3*f_d + 2*(3**0.5)*t_w) + 2*(((br_w**2)*(9*(br_w**2) - 18*br_w*f_d + 9*(f_d**2) - 2*(3**0.5)*br_w*t_w + 3*(t_w**2)))**0.5)) / (6*(2**0.5)*br_w)
  sz = (br_w*(6*br_w - 3*f_d - 2*(3**0.5)*t_w) + 2*(((br_w**2)*(9*(br_w**2) - 18*br_w*f_d + 9*(f_d**2) - 2*(3**0.5)*br_w*t_w + 3*(t_w**2)))**0.5)) / (6*(2**0.5)*br_w)

  tip_point1 = Geom::Point3d.new(px,0,pz).transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,45.degrees))
  tip_point2 = tip_point1.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))
  tip_point3 = tip_point2.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))

  tip_point4 = Geom::Point3d.new(sx,0,sz).transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,45.degrees))
  tip_point5 = tip_point4.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))
  tip_point6 = tip_point5.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))

  tip_points = [   #makes a list of tip points whose index is lined up with the index of the base point list
    tip_point3,
    tip_point4,
    tip_point2,
    tip_point6,
    tip_point1,
    tip_point5
  ]

  # MAKE BRANCH CORE AND BRANCH TIP SEPARATE
  if inputs[4].to_f == 0

    #Create Truncated Tip Points (Note: vx, vz, wx, wz use formulas that are derived in Joseph Burkhart's 2017-2018 lab notebook)
    n = inputs[5].to_l
    vx = -(2*(2**0.5)*br_w - 3*(2**0.5)*f_d + 4*(3**0.5)*n)*(br_w*(3*br_w - 6*f_d + (3**0.5)*t_w) + (((br_w**2)*(9*(br_w**2) - 18*br_w*f_d + 9*(f_d**2) - 2*(3**0.5)*br_w*t_w + 3*(t_w**2)))**0.5)) / (6*(2**0.5)*br_w*(2*br_w - 3*f_d))
    vz = ((3*f_d) / (2*(2**0.5))) - (3**0.5)*n + (2*(2**0.5)*br_w - 3*(2**0.5)*f_d + 4*(3**0.5)*n)*(br_w*(3*br_w - 6*f_d + (3**0.5)*t_w) + (((br_w**2)*(9*(br_w**2) - 18*br_w*f_d + 9*(f_d**2) - 2*(3**0.5)*br_w*t_w + 3*(t_w**2)))**0.5)) / (6*br_w*(2*br_w - 3*f_d))

    wx = (1 / (6*(2**0.5)*br_w*(4*br_w - 3*f_d)))*(-12*(2**0.5)*(br_w**3) + (br_w**2)*(33*(2**0.5)*f_d - 36*(3**0.5)*n + 4*(6**0.5)*t_w) + (3*(2**0.5)*f_d - 4*(3**0.5)*n)*(((br_w**2)*(9*(br_w**2) - 2*br_w*(9*f_d + (3**0.5)*t_w) + 3*(3*(f_d**2) + (t_w**2))))**0.5) + br_w*(-18*(2**0.5)*(f_d**2) + 24*(3**0.5)*f_d*n - 3*(6**0.5)*f_d*t_w + 12*n*t_w - 4*(2**0.5)*(((br_w**2)*(9*(br_w**2) - 18*br_w*f_d + 9*(f_d**2) - 2*(3**0.5)*br_w*t_w + 3*(t_w**2)))**0.5)))
    wz = (1 / (12*br_w*(4*br_w - 3*f_d)))*(24*(2**0.5)*(br_w**3) + (br_w**2)*(-30*(2**0.5)*f_d + 24*(3**0.5)*n - 8*(6**0.5)*t_w) + 2*(-3*(2**0.5)*f_d + 4*(3**0.5)*n)*(((br_w**2)*(9*(br_w**2) - 2*br_w*(9*f_d + (3**0.5)*t_w) + 3*(3*(f_d**2) + (t_w**2))))**0.5) + br_w*(9*(2**0.5)*(f_d**2) - 24*n*t_w + 6*(3**0.5)*f_d*(-2*n + (2**0.5)*t_w) + 8*(2**0.5)*(((br_w**2)*(9*(br_w**2) - 18*br_w*f_d + 9*(f_d**2) - 2*(3**0.5)*br_w*t_w + 3*(t_w**2)))**0.5)))

    truncated_tip_point1 = Geom::Point3d.new(vx,0,vz).transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,45.degrees))
    truncated_tip_point2 = truncated_tip_point1.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))
    truncated_tip_point3 = truncated_tip_point2.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))

    truncated_tip_point4 = Geom::Point3d.new(wx,0,wz).transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,45.degrees))
    truncated_tip_point5 = truncated_tip_point4.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))
    truncated_tip_point6 = truncated_tip_point5.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))

    truncated_tip_points = [    #makes a list of truncated tip points whose index is lined up with the index of the base point list
      truncated_tip_point3,
      truncated_tip_point4,
      truncated_tip_point2,
      truncated_tip_point6,
      truncated_tip_point1,
      truncated_tip_point5
    ]

    #Connect Base Points with Truncated Tip Points
    facs_core = [
      ent.add_face(base_points[1],base_points[0],truncated_tip_points[0],truncated_tip_points[1]), # the specific order of these points causes the faces to be right-side-out
      ent.add_face(base_points[1],base_points[2],truncated_tip_points[2],truncated_tip_points[1]),
      ent.add_face(base_points[2],base_points[3],truncated_tip_points[3],truncated_tip_points[2]),
      ent.add_face(base_points[3],base_points[4],truncated_tip_points[4],truncated_tip_points[3]),
      ent.add_face(base_points[4],base_points[5],truncated_tip_points[5],truncated_tip_points[4]),
      ent.add_face(base_points[5],base_points[0],truncated_tip_points[0],truncated_tip_points[5]),
      ent.add_face(truncated_tip_points[0],truncated_tip_points[1],truncated_tip_points[2],truncated_tip_points[3],truncated_tip_points[4],truncated_tip_points[5])
    ]
    facs_core_group = ent.add_group(facs_core)

    #Connect Truncated Tip Points with Tip Points
    facs_tip = [
      ent.add_face(truncated_tip_points[0],truncated_tip_points[1],truncated_tip_points[2],truncated_tip_points[3],truncated_tip_points[4],truncated_tip_points[5]),
      ent.add_face(truncated_tip_points[0],truncated_tip_points[1],tip_points[1],tip_points[0]),
      ent.add_face(truncated_tip_points[1],truncated_tip_points[2],tip_points[2],tip_points[1]),
      ent.add_face(truncated_tip_points[2],truncated_tip_points[3],tip_points[3],tip_points[2]),
      ent.add_face(truncated_tip_points[3],truncated_tip_points[4],tip_points[4],tip_points[3]),
      ent.add_face(truncated_tip_points[4],truncated_tip_points[5],tip_points[5],tip_points[4]),
      ent.add_face(truncated_tip_points[5],truncated_tip_points[0],tip_points[0],tip_points[5]),
      ent.add_face(tip_points[0],tip_points[1],tip_points[2],tip_points[3],tip_points[4],tip_points[5])
    ]
    facs_tip_group = ent.add_group(facs_tip)

  # MAKE BRANCH CORE AND BRANCH TIP TOGETHER
  elsif inputs[4].to_f == 1

    #Connect Base Points with Tip Points
    facs = [
      ent.add_face(base_points[1],base_points[0],tip_points[0],tip_points[1]), #the specific order of these points causes the face to be right-side-out
      ent.add_face(base_points[1],base_points[2],tip_points[2],tip_points[1]),
      ent.add_face(base_points[2],base_points[3],tip_points[3],tip_points[2]),
      ent.add_face(base_points[3],base_points[4],tip_points[4],tip_points[3]),
      ent.add_face(base_points[4],base_points[5],tip_points[5],tip_points[4]),
      ent.add_face(base_points[5],base_points[0],tip_points[0],tip_points[5]),
      ent.add_face(tip_points[0],tip_points[1],tip_points[2],tip_points[3],tip_points[4],tip_points[5])
    ]
    facs_group = ent.add_group(facs)
  end


## --- CREATE STELLA OCTANGULA
elsif inputs[3].to_f == 1

  # CREATE BASE POINTS
  base_points = [
    Geom::Point3d.new(0,br_w / (2**0.5),0),
    Geom::Point3d.new(br_w / (2**0.5),0,0),
    Geom::Point3d.new(0,0,br_w / (2**0.5))
  ]

  # CREATE TIP POINTS (Note: qx, qz use formulas derived in Joseph Burkhart's lab notebook)
  qx = (f_d / 2) + ((2*(((br_w**2)*((2*br_w - 3*f_d)**2)*(t_w**2))**0.5)) / ((3**0.5)*(6*(br_w**2) - 9*br_w*f_d)))
  qz = (9*f_d + (8*(3**0.5)*br_w*(-2*br_w + 3*f_d)*(t_w**2)) / (((br_w**2)*((2*br_w - 3*f_d)**2)*(t_w**2))**0.5)) / (18*(2**0.5))

  tip_point1 = Geom::Point3d.new(qx,0,qz).transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,45.degrees))
  tip_point2 = tip_point1.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))
  tip_point3 = tip_point2.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))

  tip_points = [
    tip_point3,
    tip_point2,
    tip_point1,
  ]

  # MAKE BRANCH CORE AND BRANCH TIP SEPARATE (Note: formulas vx, vz were obtained by Joseph Burkhart according to the derivation in his lab notebook)
  if inputs[4].to_f == 0
    n = inputs[5].to_l
    vx = ((2*(2**0.5)*br_w - 3*(2**0.5)*f_d + 4*(3**0.5)*n)*(9*br_w*(2*br_w - 3*f_d)*f_d + 4*(3**0.5)*(((br_w**2)*((2*br_w - 3*f_d)**2)*(t_w**2))**0.5))) / (18*(2**0.5)*br_w*((2*br_w - 3*f_d)**2))
    vz = ((3*f_d) / (2*(2**0.5))) - (3**0.5)*n - (((2*(2**0.5)*br_w - 3*(2**0.5)*f_d + 4*(3**0.5)*n)*(9*br_w*(2*br_w - 3*f_d)*f_d + 4*(3**0.5)*(((br_w**2)*((2*br_w - 3*f_d)**2)*(t_w**2))**0.5))) / (18*br_w*((2*br_w - 3*f_d)**2)))

  truncated_tip_point1 = Geom::Point3d.new(vx,0,vz).transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,45.degrees))
  truncated_tip_point2 = truncated_tip_point1.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))
  truncated_tip_point3 = truncated_tip_point2.clone.transform!(Geom::Transformation.rotation(ORIGIN,Geom::Vector3d.new(1,1,1),120.degrees))

  truncated_tip_points = [
    truncated_tip_point3,
    truncated_tip_point2,
    truncated_tip_point1
  ]

  #Connect Base Points with Truncated Tip Points
  facs_core = [
    ent.add_face(base_points[1],base_points[0],truncated_tip_points[0],truncated_tip_points[1]), #the specific order of these points causes the face to be right-side-out
      ent.add_face(base_points[1],base_points[2],truncated_tip_points[2],truncated_tip_points[1]),
      ent.add_face(base_points[2],base_points[0],truncated_tip_points[0],truncated_tip_points[2]),
      ent.add_face(truncated_tip_points[0],truncated_tip_points[1],truncated_tip_points[2])
  ]
  facs_core_group = ent.add_group(facs_core)

  #Connect Truncated Tip Points with Tip Points
  facs_tip = [
    ent.add_face(truncated_tip_points[0],truncated_tip_points[1],truncated_tip_points[2]),
      ent.add_face(truncated_tip_points[0],truncated_tip_points[1],tip_points[1],tip_points[0]),
      ent.add_face(truncated_tip_points[1],truncated_tip_points[2],tip_points[2],tip_points[1]),
      ent.add_face(truncated_tip_points[2],truncated_tip_points[0],tip_points[0],tip_points[2]),
      ent.add_face(tip_points[0],tip_points[1],tip_points[2])
  ]
  facs_tip_group = ent.add_group(facs_tip)


  # MAKE BRANCH CORE AND BRANCH TIP TOGETHER
  elsif inputs[4].to_f == 1

    #Connect Base Points with Tip Points
    facs = [
      ent.add_face(base_points[1],base_points[0],tip_points[0],tip_points[1]), # the specific order of these points causes the face to be right-side-out
      ent.add_face(base_points[1],base_points[2],tip_points[2],tip_points[1]),
      ent.add_face(base_points[2],base_points[0],tip_points[0],tip_points[2]),
      ent.add_face(tip_points[0],tip_points[1],tip_points[2])
    ]
    facs_group = ent.add_group(facs)
  end
end


## --- ROTATE/COPY BRANCH TO MAKE REST OF THE PARTICLE

# KEEP CORE AND TIPS SEPARATE
if inputs[4].to_f == 0

  #Group Core
  core_group0 = facs_core_group
  core_group1 = core_group0.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))
  core_group2 = core_group1.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))
  core_group3 = core_group2.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))

  core_big_group0 = ent.add_group(core_group0,core_group1,core_group2,core_group3)
  core_big_group1 = core_big_group0.copy.transform!(Geom::Transformation.rotation(ORIGIN,Y_AXIS,180.degrees))

  #Group Tips
  tips_group0 = facs_tip_group
  tips_group1 = tips_group0.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))
  tips_group2 = tips_group1.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))
  tips_group3 = tips_group2.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))

  tips_big_group0 = ent.add_group(tips_group0,tips_group1,tips_group2,tips_group3)
  tips_big_group1 = tips_big_group0.copy.transform!(Geom::Transformation.rotation(ORIGIN,Y_AXIS,180.degrees))

# KEEP CORE AND TIPS TOGETHER
elsif inputs[4].to_f == 1

  #Group Branches
  my_group0 = facs_group
  my_group1 = my_group0.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))
  my_group2 = my_group1.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))
  my_group3 = my_group2.copy.transform!(Geom::Transformation.rotation(ORIGIN,Z_AXIS,90.degrees))

  my_big_group0 = ent.add_group(my_group0,my_group1,my_group2,my_group3)
  my_big_group1 = my_big_group0.copy.transform!(Geom::Transformation.rotation(ORIGIN,Y_AXIS,180.degrees))
end


## --- EXPLODE GROUPS AND EXPORT AS .STL

# EXPORT SETTINGS
STL_ASCII = 'ASCII'.freeze
options = {
  'selection_only' => false,
  'export_units'   => 'Meters',
  'stl_format'     => STL_ASCII
}


# KEEP CORE AND TIPS SEPARATE
if inputs[4].to_f == 0
  tips_big_group0.hidden=true #hidden geometry does not get fed into the STL exporter
  tips_big_group1.hidden=true
  CommunityExtensions::STL::Exporter.export(directory+"/"+shapename+"_CORE_"+dimensions+"_TipDepth#{n}"+".stl",mod.active_entities.grep(Sketchup::Group),options) #export core
  tips_big_group0.hidden=false
  tips_big_group1.hidden=false

  core_big_group0.hidden=true
  core_big_group1.hidden=true
  CommunityExtensions::STL::Exporter.export(directory+"/"+shapename+"_TIPS_"+dimensions+"_TipDepth#{n}"+".stl", mod.active_entities.grep(Sketchup::Group), options) #export tips
  core_big_group0.hidden=false
  core_big_group1.hidden=false

# KEEP CORE AND TIPS TOGETHER
elsif inputs[4].to_f == 1
  ent.each{|e|e.explode if e.class==Sketchup::Group} #Source: https://sketchucation.com/forums/viewtopic.php?f=180&t=21137
  CommunityExtensions::STL::Exporter.export(directory+"/"+shapename+dimensions+".stl", mod.active_entities.grep(Sketchup::Face), options) #export all faces
end


## --- SAVE WHOLE MODEL AS .SKP
mod.save(directory+"/"+shapename+dimensions+".skp")
