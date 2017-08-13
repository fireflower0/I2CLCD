;; Load packages
(load "packages.lisp" :external-format :utf-8)

(in-package :cl-cffi)

;; Load wrapper API
(load "libwiringPi.lisp" :external-format :utf-8)

;; I2C device address (0x3e)
(defconstant +i2c-addr+ #X3E)

;; LCD contrast (0x00-0x0F)
(defconstant +contrast+ #X0A)

(defun i2c-lcd ()
  (setq fd (wiringPiI2CSetup +i2c-addr+))

  (setq fcnt (logior (logand +contrast+ #X0F) #X70))
  
  (wiringPiI2CWriteReg8 fd #X00 #X38) ; Function set : 8bit, 2 line
  (wiringPiI2CWriteReg8 fd #X00 #X39) ; Function set : 8bit, 2 line, IS=1
  (wiringPiI2CWriteReg8 fd #X00 #X14) ; Internal OSC freq
  (wiringPiI2CWriteReg8 fd #X00 fcnt) ; Contrast set
  (wiringPiI2CWriteReg8 fd #X00 #X5F) ; Power/ICON/Constract
  (wiringPiI2CWriteReg8 fd #X00 #X6A) ; Follower control
  (delay 300)                         ; Wait time (300 ms)
  (wiringPiI2CWriteReg8 fd #X00 #X38) ; Function set : 8 bit, 2 line, IS=0
  (wiringPiI2CWriteReg8 fd #X00 #X06) ; Entry mode set
  (wiringPiI2CWriteReg8 fd #X00 #X0C) ; Display on/off
  (wiringPiI2CWriteReg8 fd #X00 #X01) ; Clear display
  (delay 30)                          ; Wait time (0.3 ms)
  (wiringPiI2CWriteReg8 fd #X00 #X02) ; Return home
  (delay 30)                          ; Wait time (0.3 ms)

  (wiringPiI2CWriteReg8 fd #X00 #X80) ; Set cursor first line

  (loop :for char :across "Hello,"
	:do (wiringPiI2CWriteReg8 fd #X40 (char-code char)))

  (wiringPiI2CWriteReg8 fd #X00 #XC0) ; Set cursor second line

  (loop :for char :across "world!"
	:do (wiringPiI2CWriteReg8 fd #X40 (char-code char))))

;; Execution
(i2c-lcd)
