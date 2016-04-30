#!/usr/bin/env roseus

#|
(cb #<darwin-cb-class #X558ac00>
 ("r_sho_pitch:0" "l_sho_pitch:1" "r_sho_roll:2" "l_sho_roll:3" "r_el:4" "l_el:5" "r_hip_yaw:6" "l_hip_yaw:7"
"r_hip_roll:8" "l_hip_roll:9" "r_hip_pitch:10" "l_hip_pitch:11" "r_knee:12" "l_knee:13"
 "r_ank_pitch:14" "l_ank_pitch:15" "r_ank_roll:16" "l_ank_roll:17" "head_pan:18" "head_tilt:19")
 #f(0.098175 -0.108913 -0.509282 0.501612 -0.098175 0.087437 -0.006136 -0.02301
 0.024544 -0.013806 -1.18423 1.15355 2.26109 -2.27336
 1.23179 -1.26247 0.039884 -0.012272 0.012272 0.161068))
(send *darwin* :joint-list)
(#<rotational-joint #X566d400 NECK> ;; head_pan:18
#<rotational-joint #X5404030 HEADL> ;; head_tilt:19
#<rotational-joint #X51537d8 PELVYL> ;; l_hip_yaw:7
#<rotational-joint #X5150d60 PELVL> ;; l_hip_roll:9
#<rotational-joint #X54b3a08 LEGUPPERL> ;; l_hip_pitch:11
#<rotational-joint #X54f1608 LEGLOWERL> ;; l_knee:13
#<rotational-joint #X54c2578 ANKLEL> ;; l_ank_pitch:15
#<rotational-joint #X54b36d8 FOOTL> ;; l_ank_roll:17
#<rotational-joint #X5694290 PELVYR> ;; r_hip_yaw:6
#<rotational-joint #X56547c8 PELVR>  ;; r_hip_roll:8
#<rotational-joint #X5657a98 LEGUPPERR> ;; r_hip_pitch:10
#<rotational-joint #X5153718 LEGLOWERR> ;; r_knee:12
#<rotational-joint #X5150f58 ANKLER>    ;; r_ank_pitch:14
#<rotational-joint #X5150e20 FOOTR>     ;; r_ank_roll:16
#<rotational-joint #X5693d68 SHOULDERL> ;; l_sho_pitch:1
#<rotational-joint #X566f368 ARMUPPERL> ;; l_sho_roll:3
#<rotational-joint #X565de68 ARMLOWERL> ;; l_el:5
#<rotational-joint #X568f058 SHOULDERR> ;; r_sho_pitch:0
#<rotational-joint #X566ee40 ARMUPPERR> ;; r_sho_roll:2
#<rotational-joint #X566f170 ARMLOWERR>);; r_el:4

|#
(ros::load-ros-manifest "roseus")
(ros::roseus "listener")

(defclass darwin-cb-class
  :super propertied-object
  :slots (angle-vector torque-vector))
(defmethod darwin-cb-class
  (:init () (ros::subscribe "robot_joint_states" sensor_msgs::JointState #'send self :darwin-cb)
	 (load "models/darwin.l") (darwin)
         (mapcar #'(lambda (j) (send j :max-joint-torque 5.0)) (send *darwin* :joint-list))
	 (setq angle-vector (send *darwin* :angle-vector))
	 (setq torque-vector (instantiate float-vector (length angle-vector)))
	 (objects (list *darwin*))
	 self)
  (:update-angle-vector
   (msg)
   (let ((v (send msg :position))
         (e (send msg :effort))
         (max-effort 0)
         max-effort-idx)
     (scale 0.001 e e)
     (dotimes (idx (length e))
       (when (>  (abs (elt e idx)) (abs  max-effort))
         (setq max-effort-idx idx)
         (setq max-effort (elt e idx))))
     (ros::ros-info  "max-effort: ~a -> ~a" (elt (send msg :name) max-effort-idx) max-effort)
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
     ;;
     (setf (elt torque-vector 0) (elt e 18)) ;; HEAD head_pan:18
     (setf (elt torque-vector 1) (- (elt e 19))) ;; HEAD head_tilt:19
     (setf (elt torque-vector 2) (- (elt e 7))) ;; PELVYL l_hip_yaw:7
     (setf (elt torque-vector 3) (elt e 9)) ;; PELVL l_hip_roll:9
     (setf (elt torque-vector 4) (- (elt e 11))) ;; LEGUPPERL l_hip_pitch:11
     (setf (elt torque-vector 5) (- (elt e 13))) ;; LEGLOWERL l_knee:13
     (setf (elt torque-vector 6) (elt e 15)) ;; ANKLEL l_ank_pitch:15
     (setf (elt torque-vector 7) (elt e 17)) ;; FOOTL l_ank_roll:17
     (setf (elt torque-vector 8) (- (elt e 6))) ;; PELVYR r_hip_yaw:6
     (setf (elt torque-vector 9) (elt e 8)) ;; PELVR r_hip_roll:8
     (setf (elt torque-vector 10) (elt e 10)) ;; LEGUPPERR r_hip_pitch:10
     (setf (elt torque-vector 11) (elt e 12)) ;; LEGLOWERR r_knee:12
     (setf (elt torque-vector 12) (- (elt e 14))) ;; ANKLER r_ank_pitch:14
     (setf (elt torque-vector 13) (elt e 16)) ;; FOOTR r_ank_roll:16
     (setf (elt torque-vector 14) (elt e 1)) ;; SHOULDERL l_sho_pitch:1
     (setf (elt torque-vector 15) (- (elt e 3))) ;; ARMUPPERL l_sho_roll:3
     (setf (elt torque-vector 16) (elt e 5)) ;; ARMLOWERL l_el:5
     (setf (elt torque-vector 17) (- (elt e 0))) ;; SHOULDERR r_sho_pitch:0
     (setf (elt torque-vector 18) (- (elt e 2))) ;; ARMUPPERR r_sho_roll:2
     (setf (elt torque-vector 19) (- (elt e 4))) ;; ARMLOWERR> r_el:4
     
     (send *darwin* :angle-vector angle-vector)
     (send *irtviewer* :draw-objects :flush nil)
     (send *darwin* :draw-torque *viewer* :torque-vector torque-vector)
     (print e)
     (send *irtviewer* :flush)
     angle-vector)
   )
  (:darwin-cb (msg)
	      (send self :update-angle-vector msg)
	      ;;(print (list 'cb self (send msg :name) (send msg :position)))
	      )
  )

(setq m (instance darwin-cb-class :init))

(do-until-key 
 (ros::spin-once)
 )
;(ros::spin)
