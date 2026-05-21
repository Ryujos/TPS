PROGRAM TPS

  USE VARIABLES
  USE EQUATIONS
  USE WRITE_REACTION_TRAJECTORY

IMPLICIT NONE

  INTEGER :: i
  REAL*8 :: x0,x,xf,time
  REAL*8 :: rand
  REAL*8, EXTERNAL :: gauss
  EXTERNAL :: setr1279

  CALL setr1279(seed)

  x0 = -1. / 2.
  xf =  1. / 2. 

  x = x0

  i = 0
  time = REAL(i) * dt

  CALL Start_Output()
  CALL Write_React_Traj(a,b,x,time)

  DO WHILE (x < xf)

    i = i + 1
    time = REAL(i) * dt

    rand = gauss()

    x = Calc_New_Pos(x,a,b,T,dt,rand)

    CALL Write_React_Traj(a,b,x,time)
    
    IF (x <= x0) THEN

      i = 0
      time = REAL(i) * dt

      CALL Start_Output()
      CALL Write_React_Traj(a,b,x,time)

    END IF

  END DO

END PROGRAM TPS
