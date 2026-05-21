PROGRAM TPS

  USE VARIABLES
  USE EQUATIONS
  USE READ_REACTION_TRAJECTORY
  USE WRITE_REACTION_TRAJECTORY

IMPLICIT NONE

  LOGICAL :: Accepted
  INTEGER :: i,k,Num_RT_Prop,n_data
  INTEGER :: cap_back,cap_forw,n_back,n_forw
  REAL*8 :: x,x_mid
  REAL*8 :: acep_rate
  REAL*8 :: rand,rand_pos,rand_pert
  INTEGER :: rand_pos_RT
  REAL*8, ALLOCATABLE :: array_RT(:),x_array_back(:),x_array_forw(:),temp(:)
  REAL*8, EXTERNAL :: gauss
  EXTERNAL :: setr1279
  CHARACTER(len=50) :: filenamear

  CALL setr1279(seed)

  x = 0

  Num_RT_Prop = 0
  k = 0
  i = 0

  n_back = 0
  n_forw = 0

  cap_back = 100
  cap_forw = 100

  !-------------------------------------
  ! Number of positions that describe 
  ! the reactive trajectory obtained by 
  ! bruce-force sampling
  !-----------------------------------

  n_data = Get_Num_Data(filename)

  ALLOCATE(array_RT(n_data),x_array_back(cap_back),x_array_forw(cap_forw))

  !-----------------------------------------------
  ! Read the initial reactive trajectory that was
  ! generated with brute-force sampling
  !-----------------------------------------------
 
  CALL Read_React_Traj(filename,array_RT,n_data)

  !-----------------------------------------------
  ! Loop to generate enough reactive trajectories
  !-----------------------------------------------

  DO WHILE (k < Num_RT_Accep)

    Accepted = .TRUE.
    n_back = 0
    n_forw = 0
    Num_RT_Prop = Num_RT_Prop + 1
    i = 0

   ! IMPLEMENT SHOOTING MOVES   

    !----------------------------------------------
    ! Selection of the random configuration that
    ! belongs to the current reactive trajectory
    !----------------------------------------------

    CALL RANDOM_NUMBER(rand_pos)

    rand_pos_RT = INT(rand_pos * REAL(n_data)) + 1

    !----------------------------------------------
    ! Perturbation of the random configuration that
    ! belongs to the current reactive trajectory
    !----------------------------------------------

    CALL RANDOM_NUMBER(rand_pert)

    x_mid = array_RT(rand_pos_RT) + pert_degree * (rand_pert - 0.5)
    x = x_mid

    !---------------------------------------------
    ! Generate the proposed reactive trajectory
    ! by integrating the dynamics forward and 
    ! backward in time
    !--------------------------------------------

    DO WHILE ((x0 < x) .AND. Accepted)

      IF (n_back == cap_back) THEN
        ALLOCATE(temp(2*cap_back))
        temp(1:cap_back) = x_array_back(1:cap_back)
        CALL MOVE_ALLOC(temp, x_array_back)
        cap_back = 2*cap_back
      END IF

      !----------------------------------------------
      ! Reactive trajectory part backward in time
      !----------------------------------------------

      n_back = n_back + 1

      rand = gauss()

      x_array_back(n_back) = Calc_New_Pos_Back(x,a,b,T,dt,rand)

      x = x_array_back(n_back)

      !---------------------------------------------------
      ! If the backward in time reactive trajectory 
      ! arrives to the region B before to the region A
      ! the proposed reactive trajectory will be rejected
      !---------------------------------------------------

      IF (x > xf) THEN 
        Accepted = .FALSE.
      END IF

      END DO

      !-----------------------------------------
      ! Return to the perturbed random position
      !-----------------------------------------

      x = x_mid

      DO WHILE ((x < xf) .AND. Accepted)

      IF (n_forw == cap_forw) THEN
        ALLOCATE(temp(2*cap_forw))
        temp(1:cap_forw) = x_array_forw(1:cap_forw)
        CALL MOVE_ALLOC(temp, x_array_forw)
        cap_forw = 2*cap_forw
      END IF

      !-------------------------------------------
      ! Reactive trajectory part forward in time
      !-------------------------------------------

      n_forw = n_forw + 1

      rand = gauss()

      x_array_forw(n_forw) = Calc_New_Pos_Forw(x,a,b,T,dt,rand)

      x = x_array_forw(n_forw)

      !---------------------------------------------------
      ! If the forward in time reactive trajectory 
      ! arrives to the region A before to the region B
      ! the proposed reactive trajectory will be rejected
      !---------------------------------------------------

      IF (x0 > x) THEN 
        Accepted = .FALSE.
      END IF

    END DO

    !-----------------------------------------------
    ! Write the full accepted reactive trajectories
    !-----------------------------------------------

    IF (Accepted) THEN 

      k = k + 1
 
      WRITE(filename,'("RT_",I0,"_T_",F4.2,"_",F5.2,"_",F4.2,"pert_degree",F4.2,".dat")')     k, T, x0, xf, pert_degree

      CALL Start_Output(filename)
      CALL Write_React_Traj_TPS(filename,a,b,x_mid,x_array_back(1:n_back),x_array_forw(1:n_forw))
     
      !-----------------------------------
      ! Number of positions that describe 
      ! the new accepted reactive
      ! trajectory
      !-----------------------------------

      n_data = Get_Num_Data(filename)
 
      DEALLOCATE(array_RT)      
      ALLOCATE(array_RT(n_data))
 
      !--------------------------------------------
      ! Read the new accepted reactive trajectory
      !--------------------------------------------

      CALL Read_React_Traj(filename,array_RT,n_data) 

    END IF

    DEALLOCATE(x_array_back,x_array_forw)
    ALLOCATE(x_array_back(cap_back),x_array_forw(cap_forw))

  END DO

  !------------------------------------------------
  ! Write the file that contains the Acceptance
  ! Rate of the proposed trajectories
  !-----------------------------------------------  

  acep_rate = REAL(k) / REAL(Num_RT_Prop)

  WRITE(filenamear,'("AR_",I0,"_T_",F4.2,"_",F5.2,"_",F4.2,"pert_degree",F4.2,".dat")')     k, T, x0, xf, pert_degree

  CALL Start_Output(filenamear)

  CALL Write_Acep_Rate(filenamear, acep_rate)
  

CONTAINS
  SUBROUTINE Write_Acep_Rate(filenamear, acep_rate)
  IMPLICIT NONE

  CHARACTER(LEN=*), INTENT(IN) :: filenamear
  REAL*8 :: acep_rate

  OPEN(1, file=filenamear, status='old', position='append', action='write')

  WRITE(1,*) acep_rate

  CLOSE(1)

END SUBROUTINE Write_Acep_Rate
  

END PROGRAM TPS
