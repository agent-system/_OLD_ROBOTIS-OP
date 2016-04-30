#!/usr/bin/env roseus

#|
 ("r_sho_pitch:0" "l_sho_pitch:1" "r_sho_roll:2" "l_sho_roll:3" "r_el:4" "l_el:5" "r_hip_yaw:6" "l_hip_yaw:7"
"r_hip_roll:8" "l_hip_roll:9" "r_hip_pitch:10" "l_hip_pitch:11" "r_knee:12" "l_knee:13"
 "r_ank_pitch:14" "l_ank_pitch:15" "r_ank_roll:16" "l_ank_roll:17" "head_pan:18" "head_tilt:19")
|#

(ros::load-ros-manifest "roseus")

(ros::roseus "listener")

(setq joint-names '("r_sho_pitch" "l_sho_pitch" "r_sho_roll" "l_sho_roll" "r_el" "l_el" "r_hip_yaw" "l_hip_yaw" "r_hip_roll" "l_hip_roll" "r_hip_pitch" "l_hip_pitch" "r_knee" "l_knee"  "r_ank_pitch" "l_ank_pitch" "r_ank_roll" "l_ank_roll" "head_pan" "head_tilt"))

;;(ros::advertise "publish_position" sensor_msgs::JointState 10)

(setq pub (ros::advertise "controller_joint_states" sensor_msgs::JointState 1))


(defclass darwin-cb-class
  :super propertied-object
  :slots (angle-vector))
(defmethod darwin-cb-class
  (:init ()
	 (dolist (name joint-names)
	   )
	 (ros::subscribe "robot_joint_states" sensor_msgs::JointState #'send self :darwin-cb)
	 (load "models/darwin.l") (darwin)
	 (setq angle-vector (send *darwin* :angle-vector))
	 (objects (list *darwin*))
	 self)
  (:update-angle-vector
   (msg)
   (let ((v (send msg :position)))
     (setf (elt angle-vector 0) (rad2deg (elt v 18))) ;; HEAD head_pan:18
     (setf (elt angle-vector 1) (- 45 (rad2deg (elt v 19)))) ;; HEAD head_tilt:19
     (setf (elt angle-vector 2) (- (rad2deg (elt v 7)))) ;; PELVYL l_hip_yaw:7
     (setf (elt angle-vector 3) (rad2deg (elt v 9))) ;; PELVL l_hip_roll:9
     (setf (elt angle-vector 4) (- (rad2deg (elt v 11)))) ;; LEGUPPERL l_hip_pitch:11
     (setf (elt angle-vector 5) (- (rad2deg (elt v 13)))) ;; LEGLOWERL l_knee:13
     (setf (elt angle-vector 6) (rad2deg (elt v 15))) ;; ANKLEL l_ank_pitch:15
     (setf (elt angle-vector 7) (rad2deg (elt v 17))) ;; FOOTL l_ank_roll:17
     (setf (elt angle-vector 8) (- (rad2deg (elt v 6)))) ;; PELVYR r_hip_yaw:6
     (setf (elt angle-vector 9) (rad2deg (elt v 8))) ;; PELVR r_hip_roll:8
     (setf (elt angle-vector 10) (rad2deg (elt v 10))) ;; LEGUPPERR r_hip_pitch:10
     (setf (elt angle-vector 11) (rad2deg (elt v 12))) ;; LEGLOWERR r_knee:12
     (setf (elt angle-vector 12) (- (rad2deg (elt v 14)))) ;; ANKLER r_ank_pitch:14
     (setf (elt angle-vector 13) (rad2deg (elt v 16))) ;; FOOTR r_ank_roll:16
     (setf (elt angle-vector 14) (rad2deg (elt v 1))) ;; SHOULDERL l_sho_pitch:1
     (setf (elt angle-vector 15) (- 45.0 (rad2deg (elt v 3)))) ;; ARMUPPERL l_sho_roll:3
     (setf (elt angle-vector 16) (+ -90.0 (rad2deg (elt v 5)))) ;; ARMLOWERL l_el:5
     (setf (elt angle-vector 17) (- (rad2deg (elt v 0)))) ;; SHOULDERR r_sho_pitch:0
     (setf (elt angle-vector 18) (- -45.0 (rad2deg (elt v 2)))) ;; ARMUPPERR r_sho_roll:2
     (setf (elt angle-vector 19) (- -90.0 (rad2deg (elt v 4)))) ;; ARMLOWERR> r_el:4
     (send *darwin* :angle-vector angle-vector)
     (send *irtviewer* :draw-objects)
     angle-vector)
   )
  (:read-write
   (msg)
   (let ((v (send msg :position))
	 (m (instance sensor_msgs::JointState :init)))
     (send msg :name (list "l_sho_pitch" "l_sho_roll" "l_el"))
     (send msg :position (float-vector (- (elt v 0)) (- (elt v 2)) (- (elt v 4))))
     (prin1 (send msg :name)) (print (send msg :position))
     (ros::publish "controller_joint_states" m)
     msg))
  (:darwin-cb
   (msg)
   (send self :update-angle-vector msg)
   ;;(print (list 'cb self (send msg :name) (send msg :position)))
   (send self :read-write msg)
   msg)
  )

(setq m (instance darwin-cb-class :init))

(do-until-key 
 (ros::spin-once)
 )
;(ros::spin)
