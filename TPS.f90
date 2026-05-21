PROGRAM TPS

  USE VARIABLES
  USE EQUATIONS
  USE WRITE_REACTION_TRAJECTORY

IMPLICIT NONE

  INTEGER :: i
  REAL*8 :: x0,x
  REAL*8 :: rand
  REAL*8, EXTERNAL :: gauss
  EXTERNAL :: setr1279

  CALL setr1279(seed)

  x0 = 0.

  x = x0

  i = 0

  CALL Start_Output()
  CALL Write_React_Traj(a,b,x)

  DO WHILE (i < N_steps)

    i = i + 1

    rand = gauss()

    x = Calc_New_Pos(x,a,b,T,dt,rand)

    CALL Write_React_Traj(a,b,x)

  END DO

END PROGRAM TPS
