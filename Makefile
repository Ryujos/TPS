FC = gfortran
FFLAGS = -Wall -Wextra -O2
TARGET = TPS

OBJ = Variables.o Equations.o Write_Reaction_Trajectory.o Read_Reaction_Trajectory.o TPS.o r1279.o gauss_only.o ran2.o

all: $(TARGET)

$(TARGET): $(OBJ)
	$(FC) $(FFLAGS) -o $@ $(OBJ)

gauss_only.f: gauss.f
	awk 'BEGIN{p=0} /^[[:space:]]*[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn][[:space:]]+[Gg][Aa][Uu][Ss][Ss][[:space:]]*\(/ {p=1} p{print} p && /^[[:space:]]*[Ee][Nn][Dd][[:space:]]*$$/ {exit}' gauss.f > gauss_only.f

gauss_only.o: gauss_only.f
	$(FC) $(FFLAGS) -c gauss_only.f

TPS.o: TPS.f90 Variables.o Equations.o Write_Reaction_Trajectory.o Read_Reaction_Trajectory.o
	$(FC) $(FFLAGS) -c TPS.f90

Write_Reaction_Trajectory.o: Write_Reaction_Trajectory.f90 Variables.o
	$(FC) $(FFLAGS) -c Write_Reaction_Trajectory.f90

Read_Reaction_Trajectory.o: Read_Reaction_Trajectory.f90 Variables.o
	$(FC) $(FFLAGS) -c Read_Reaction_Trajectory.f90

Equations.o: Equations.f90 Variables.o
	$(FC) $(FFLAGS) -c Equations.f90

Variables.o: Variables.f90
	$(FC) $(FFLAGS) -c Variables.f90

r1279.o: r1279.f90 r1279block.h
	$(FC) $(FFLAGS) -c r1279.f90

ran2.o: ran2.f
	$(FC) $(FFLAGS) -c ran2.f

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET) *.mod gauss_only.f
.PHONY: all run clean
