#!/usr/bin/env bash
set -euo pipefail

VAR_FILE="Variables.f90"
RUN_SCRIPT="./Ejex.sh"
BASE_DIR="Experimentos"
BACKUP_FILE="${VAR_FILE}.backup_experimentos"

T_VALUES=("0.05D0" "0.1D0" "0.2D0" "0.4D0" "0.8D0")
X0_VALUES=("-0.5D0" "-0.65D0" "-0.7071067811865475D0" "-0.85D0" "-1.0D0")
XF_VALUES=("0.5D0" "0.65D0" "0.7071067811865475D0" "0.85D0" "1.0D0")
PERT_VALUES=("0.01D0" "0.1D0" "0.5D0" "1.0D0" "2.0D0")

if [[ ! -f "$VAR_FILE" ]]; then
  echo "Error: no existe $VAR_FILE en el directorio actual." >&2
  exit 1
fi

if [[ ! -f "$RUN_SCRIPT" ]]; then
  echo "Error: no existe $RUN_SCRIPT en el directorio actual." >&2
  exit 1
fi

if [[ ! -x "$RUN_SCRIPT" ]]; then
  chmod +x "$RUN_SCRIPT"
fi

cp "$VAR_FILE" "$BACKUP_FILE"

restore_original() {
  if [[ -f "$BACKUP_FILE" ]]; then
    cp "$BACKUP_FILE" "$VAR_FILE"
    rm -f "$BACKUP_FILE"
  fi
}
trap restore_original EXIT

mkdir -p "$BASE_DIR/T" "$BASE_DIR/x0_xf" "$BASE_DIR/pert_degree"

update_variables() {
  local newT="${1:-}"
  local newX0="${2:-}"
  local newXF="${3:-}"
  local newP="${4:-}"
  local tmp_file
  tmp_file=$(mktemp "${TMPDIR:-/tmp}/variables.XXXXXX")

  awk -v newT="$newT" -v newX0="$newX0" -v newXF="$newXF" -v newP="$newP" '
    {
      if (newT  != "" && $0 ~ /^[[:space:]]*REAL\*8[[:space:]]*::[[:space:]]*T[[:space:]]*=/) {
        print "  REAL*8  :: T  = " newT
        next
      }
      if (newP  != "" && $0 ~ /^[[:space:]]*REAL\*8[[:space:]]*::[[:space:]]*pert_degree[[:space:]]*=/) {
        print "  REAL*8  :: pert_degree = " newP
        next
      }
      if (newX0 != "" && $0 ~ /^[[:space:]]*REAL\*8[[:space:]]*::[[:space:]]*x0[[:space:]]*=/) {
        print "  REAL*8  :: x0 = " newX0
        next
      }
      if (newXF != "" && $0 ~ /^[[:space:]]*REAL\*8[[:space:]]*::[[:space:]]*xf[[:space:]]*=/) {
        print "  REAL*8  :: xf = " newXF
        next
      }
      print
    }
  ' "$VAR_FILE" > "$tmp_file"

  mv "$tmp_file" "$VAR_FILE"
}

sanitize_tag() {
  local value="$1"

  value="${value%D0}"
  value="${value// /}"
  value="${value//-/neg_}"
  value="${value//+/pos_}"
  value="${value//./p}"
  value="${value//\//_over_}"
  value="${value//\*/x}"
  value="${value//(/}"
  value="${value//)/}"

  echo "$value"
}

run_and_collect() {
  local outdir="$1"
  local stamp_file="$outdir/.run_started"

  mkdir -p "$outdir"
  : > "$stamp_file"
  sleep 1

  echo "----------------------------------------"
  echo "Ejecutando experimento en: $outdir"
  echo "----------------------------------------"

  {
    echo "Directorio del experimento: $outdir"
    echo
    echo "Parámetros usados en Variables.f90:"
    grep -E "^[[:space:]]*REAL\*8[[:space:]]*::[[:space:]]*(T|x0|xf|pert_degree)[[:space:]]*=" "$VAR_FILE" || true
    echo
    echo "Salida de compilación y ejecución:"
    bash "$RUN_SCRIPT"
  } | tee "$outdir/run.log"

  # Guardar parámetros y código usado
  cp "$VAR_FILE" "$outdir/"
  cp *.f90 "$outdir/" 2>/dev/null || true
  cp Makefile "$outdir/" 2>/dev/null || true
  cp makefile "$outdir/" 2>/dev/null || true
  cp "$RUN_SCRIPT" "$outdir/" 2>/dev/null || true
  cp "$0" "$outdir/Run_Experiments_mac.sh" 2>/dev/null || true

  # Guardar información de entorno
  date > "$outdir/date.txt"
  gfortran --version > "$outdir/compiler_version.txt" 2>/dev/null || true

  # Mover resultados .dat generados en esta ejecución
  while IFS= read -r -d '' generated_file; do
    mv "$generated_file" "$outdir/"
  done < <(find . -maxdepth 1 -type f -name '*.dat' ! -name 'React_Traj.dat' -newer "$stamp_file" -print0)

  # Copiar ejecutable si se ha generado
  if [[ -f TPS && TPS -nt "$stamp_file" ]]; then
    cp TPS "$outdir/"
  fi

  rm -f "$stamp_file"
}

# 1) Variar SOLO T
for Tval in "${T_VALUES[@]}"; do
  cp "$BACKUP_FILE" "$VAR_FILE"
  update_variables "$Tval" "" "" ""

  tag=$(sanitize_tag "$Tval")
  outdir="$BASE_DIR/T/T_${tag}"
  run_and_collect "$outdir"
done

# 2) Variar SOLO x0 y xf
for i in "${!X0_VALUES[@]}"; do
  cp "$BACKUP_FILE" "$VAR_FILE"
  update_variables "" "${X0_VALUES[$i]}" "${XF_VALUES[$i]}" ""

  tag_x0=$(sanitize_tag "${X0_VALUES[$i]}")
  tag_xf=$(sanitize_tag "${XF_VALUES[$i]}")
  outdir="$BASE_DIR/x0_xf/x0_${tag_x0}_xf_${tag_xf}"
  run_and_collect "$outdir"
done

# 3) Variar SOLO pert_degree
for pval in "${PERT_VALUES[@]}"; do
  cp "$BACKUP_FILE" "$VAR_FILE"
  update_variables "" "" "" "$pval"

  tag=$(sanitize_tag "$pval")
  outdir="$BASE_DIR/pert_degree/pert_degree_${tag}"
  run_and_collect "$outdir"
done

echo
echo "Todos los experimentos han terminado."
echo "Resultados guardados en: $BASE_DIR"
