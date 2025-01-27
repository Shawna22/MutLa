#Align all frames to the first frame
# Select the reference region (blue region)
set ref_sel "resid 331 to 508 or resid 863 to 1040"
set ref [atomselect top $ref_sel frame 0]

# Get the number of frames
set num_frames [molinfo top get numframes]

# Loop through all frames and align them to the reference region
for {set i 0} {$i < $num_frames} {incr i} {
    # Select the region to be aligned (blue region)
    set sel [atomselect top $ref_sel frame $i]
    
    # Calculate the transformation matrix to align the selected region to the reference region
    set transformation_matrix [measure fit $sel $ref]
    
    # Apply the transformation matrix to the entire molecule
    set move_sel [atomselect top "all" frame $i]
    
    # Move the selected atoms to align with the reference atoms
    $move_sel move $transformation_matrix
    
    # Delete the selections
    $sel delete
    $move_sel delete
}

# Delete the reference selection
$ref delete

puts "All frames have been aligned to frame 0."