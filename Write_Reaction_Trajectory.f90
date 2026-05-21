MODULE WRITE_REACTION_TRAJECTORY

  USE EQUATIONS

IMPLICIT NONE

CONTAINS

  !-------------------------------------------------------
  ! Subroutine to created the files that will contain a
  ! accepted reactive trajectory or the acceptance rate
  ! of the proposed reactive trajectories
  ! RT -> Accepted Reactive Trajectory number X
  ! AR -> Acceptance Rate
  ! All the files contains the same header (not correct
  ! for AC)
  !------------------------------------------------------

  SUBROUTINE Start_Output(filename)
 
     CHARACTER(LEN=*) :: filename

     OPEN(1, file=filename, status="new")
 
     WRITE(1,*) "Reaction Trajectory"
     WRITE(1,*) "Time (t)     Position (x)             Potential     (V)"
 
     CLOSE(1)
 
  END SUBROUTINE Start_Output

  !----------------------------------------
  ! Write the reactive trajectory sampled
  ! by bruce-force sampling
  !---------------------------------------

  SUBROUTINE Write_React_Traj(filename,a,b,x,time)

    CHARACTER(LEN=*) :: filename
    REAL*8 :: Pot
    REAL*8, INTENT(IN) :: a,b,x,time

    Pot = Calc_Potential(a,b,x)

    OPEN(1, file=filename, status="old", position="append")          

    WRITE(1,*) time, x, Pot

    CLOSE(1)

  END SUBROUTINE Write_React_Traj

  !------------------------------------------
  ! Write the accepted reactive trajectories
  !------------------------------------------

  SUBROUTINE Write_React_Traj_TPS(filename, a, b, x_mid, array_back, array_forw)
  USE VARIABLES, ONLY: dt
  IMPLICIT NONE

  CHARACTER(LEN=*), INTENT(IN) :: filename
  REAL(8), INTENT(IN) :: a, b, x_mid
  REAL(8), INTENT(IN) :: array_back(:), array_forw(:)

  INTEGER :: i, n_back, n_forw, unitn
  REAL(8) :: time, x, pot

  n_back = SIZE(array_back)
  n_forw = SIZE(array_forw)

  unitn = 20

  OPEN(unit=unitn, file=filename, status='old', position='append', action='write')

  time = 0.0D0

  !--------------------------------------------
  ! Write the part of the trajectory backwards
  !--------------------------------------------

  DO i = n_back, 1, -1
    x = array_back(i)
    pot = Calc_Potential(a, b, x)
    WRITE(unitn,*) time, x, pot
    time = time + dt
  END DO

  !------------------------------------------
  ! Write the random perturbed configuration
  ! that generates a reactive trajectory that
  ! has been already accepted
  !------------------------------------------

  x = x_mid
  pot = Calc_Potential(a, b, x)
  WRITE(unitn,*) time, x, pot
  time = time + dt

  !-------------------------------------------
  ! Write the part of the trajectory forwards
  !-------------------------------------------

  DO i = 1, n_forw
    x = array_forw(i)
    pot = Calc_Potential(a, b, x)
    WRITE(unitn,*) time, x, pot
    time = time + dt
  END DO

  CLOSE(unitn)

END SUBROUTINE Write_React_Traj_TPS

END MODULE WRITE_REACTION_TRAJECTORY
