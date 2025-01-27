# This is a script for visualizing 4 key conformational changes of MutLα

#usage: In tcl console
#Step 1: source traj.vmd
#Step 2: source Align_all_frame.tcl
#Step 3:
        #option 1
        #Rotate the molecule to find the best view of the key conformations
        #save_vp 0 #save viewpoint 0-n
        #write_vps your_viewpoint_file.tcl #save the all viewpoints to a file
        #retrieve 0 #Turn back to the initial state

        #option 2
        #source your_viewpoint_file.tcl
#Step 4: init_animation


#source files
#source traj.vmd
#source Align_all_frame.tcl
source la.tcl
source orient.tcl
source visualization.tcl

#Variables
set start_frame 12800
set end_frame 16069
set key_frames {12883 15757 15904 16068}
set key_frame_distance 20 ;#To adjust the animation speed
set default_speed 1.0

# Calculate the animation speed
proc calculate_speed {current_frame key_frames} {
    global key_frame_distance
    set speed 1.0
    foreach key_frame $key_frames {
        set distance [expr $current_frame - $key_frame]
        if {$distance >= -($key_frame_distance) && $distance <= 0} {
            # Linear change between speeds 1 and 0.x before the key frame
            set speed [expr 1.0 - 0.01 * ($key_frame_distance + $distance)]
            break
        } elseif {$distance > 0 && $distance <= $key_frame_distance} {
            # Linear change between speeds 0.x and 1 after the key frame
            set speed [expr 1 - 0.01 * ($key_frame_distance - $distance)]
            break
        }
    }
    return $speed
}

# Stop animation at key frame or end frame
proc stop_animation {} {
    global end_frame key_frames
    set current_frame [set ::vmd_frame(0)] ;# Get the current frame

    # Calculate speed
    set speed [calculate_speed $current_frame $key_frames]
    animate speed $speed

    # Check if the animation should pause or continue
    if {$current_frame >= $end_frame} {
        animate pause
        puts "Animation paused at frame $current_frame"
    } else {
        set key_frame_index [lsearch $key_frames $current_frame]
        if {$key_frame_index != -1} {
            animate pause
            puts "Paused at key frame $current_frame"

            #Rotate the view
            set from_viewpoint $key_frame_index
            set to_viewpoint [expr {$key_frame_index + 1}]
            move_vp $from_viewpoint $to_viewpoint 300 

            #Pause for 3 seconds and then continue 
            after 3000 "animate forward; after 100 stop_animation"
        } else {
            after 100 stop_animation ;# Wait for 100ms and check the frame number
        }
    }
}

# Initialize the animation
proc init_animation {} {
    global start_frame default_speed

    #Smooth the 8 representations for molecule 0
    for {set i 0} {$i < 8} {incr i} {
    mol smoothrep 0 $i 10
    }

    
    animate speed $default_speed

    animate goto $start_frame

    animate forward

    after 100 stop_animation
}


# Add a trace to check the frame number continuously and stop when reaching the end frame or key frames
trace variable ::vmd_frame(0) w stop_animation
