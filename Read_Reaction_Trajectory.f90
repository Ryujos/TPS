MODULE READ_REACTION_TRAJECTORY
IMPLICIT NONE
CONTAINS

  !----------------------------------------------
  ! Obtain the number of positions that describe 
  ! the actual reactive trajectory
  !----------------------------------------------

  FUNCTION Get_Num_Data(filename) RESULT(n_data)
  IMPLICIT NONE

    CHARACTER(LEN=*), INTENT(IN) :: filename
    INTEGER :: n_data,ios
    INTEGER :: n_total
    CHARACTER(LEN=10) :: line
    REAL*8 :: data

    n_total = 0

    OPEN(unit=1, file=filename, status='old', action='read')

      READ(1,'(A)',IOSTAT=ios) line
       READ(1,'(A)',IOSTAT=ios) line

      DO
    
        READ(1, *,IOSTAT=ios) data,data,data
        IF (ios /= 0) EXIT
        n_total = n_total + 1
   
      end do

    close(1)

    n_data = n_total

  END FUNCTION Get_Num_Data

  !-------------------------------------------
  ! Read the current reactive trajectory 
  !-------------------------------------------

  SUBROUTINE Read_React_Traj(filename,array_RT,n_data)
  IMPLICIT NONE

     CHARACTER(LEN=*), INTENT(IN) :: filename
     CHARACTER(LEN=10) :: headings
     INTEGER :: n_data,i,ios
     REAL*8,INTENT(OUT) :: array_RT(:)
     REAL*8 :: x,time,pot

     OPEN(unit=1, file=filename, status='old', action='read')

       i = 0

       READ(1,*) headings
       READ(1,*) headings

       DO

         READ(1,*,IOSTAT=ios) time, x, pot
         IF (ios /= 0) EXIT
         i = i+1
         array_RT(i) = x

       END DO

     CLOSE(1)
  END SUBROUTINE Read_React_Traj

END MODULE READ_REACTION_TRAJECTORY
