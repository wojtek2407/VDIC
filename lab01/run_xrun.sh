# tested with XCELIUM 19.09

# Commmand arguments:
# -g          - starts xrun simulation with gui, with separate database
# -q          - xrun quiet operation, less information on screen
# -d          - define verilog `DEBUG macro
# -f <file.f> - use file.f instead of the default tb.f 
# -c          - run imc after simulation to merge the coverage results and
#               display the statistics

# To set the paths for xrun and imc, execute the following command in the terminal:
# source /cad/env/cadence_path.XCELIUM1909

# Help library if available with command:
# cdnshelp &

#------------------------------------------------------------------------------
# The list of tests; in GUI mode only the first test is started.
TESTS=(lab01);
#------------------------------------------------------------------------------
# Default .f file
FFILE="tb.f"
#------------------------------------------------------------------------------
# MAIN
function main(){
  xrun_compile
  xrun_elaborate
  xrun_run_all_tests
  if [[ "$RUN_IMC" != "" ]]; then
    run_imc
  fi
}
#------------------------------------------------------------------------------
# local variables#<<<
XCELIUM_CONFIG="/cad/env/cadence_path.XCELIUM1909";
INCA="INCA_libs"
GUI=""
QUIET=""
DEBUG=""
RUN_IMC=""
#>>>
#------------------------------------------------------------------------------
# check input script arguments and env#<<<
while getopts cdf:gq option
  do case "${option}" in
    g) GUI="+access+r +gui"; INCA="${INCA}_gui";;
    q) QUIET="-q";;
    d) DEBUG="-define DEBUG";;
    f) FFILE=$OPTARG;;
    c) RUN_IMC=1;;
    *) echo -e "Valid option are: \n-g - for GUI \n-q - for quiet run"; 
       echo -e "-d - set DEBUG verilog macro"
       echo -e "-f <file.f> (default: tb.f)"
       echo -e "-c - run coverage analysis (merge coverage results)"
       exit -1 ;;
  esac
done
#>>>
#------------------------------------------------------------------------------
# init #<<<
rm -rf $INCA      # remove previous database
rm -rf cov_work   # remove previous coverage results
cols=`tput cols`
separator=`perl -e "print \"#\" x $cols"` >> /dev/null 2>&1
which xrun >> /dev/null 2>&1
if [[ "$?" != "0" ]]; then
  echo ERROR: xrun simulator not found. Execute the command:
  echo source $XCELIUM_CONFIG
  exit -1
fi
#>>>
#------------------------------------------------------------------------------
# simulator arguments #<<<
COV_ARGS=""
if [[ "$RUN_IMC" != "" ]]; then
  COV_ARGS="-coverage all -covoverwrite -covfile xrun_covfile.txt" 
fi
XRUN_ARGS="\
  -F $FFILE \
  -v93 \
  $QUIET \
  $DEBUG \
  +nowarnDSEM2009 \
  +nowarnDSEMEL \
  +nowarnCGDEFN \
  -xmlibdirname $INCA \
  $GUI \
  +overwrite \
  -nocopyright \
  $COV_ARGS \
"
#>>>
#------------------------------------------------------------------------------
# PROCEDURES
#------------------------------------------------------------------------------
function xrun_info() { #<<<
  # Prints string between separators
  # args: string
  echo $separator
  echo "$*"
  echo $separator
  return 0
} #>>>
#------------------------------------------------------------------------------
function xrun_check_status() { #<<<
  # Checks the status of the action;
  # args: int (status), string (action name)

  status=$1
  action=$2

  if [[ "$status" != "0" ]]; then
    echo "$action failed with status $status".
    exit -1
  fi
  echo $action finished with status 0.
  return 0
} #>>>
#------------------------------------------------------------------------------
function xrun_compile() { #<<<
  xrun_info "# Compiling. Log saved to xrun_compile.log"
  xrun -compile -l xrun_compile.log $XRUN_ARGS 
  xrun_check_status $? "Compilation"
} #>>>
#------------------------------------------------------------------------------
function xrun_elaborate() { #<<<
  xrun_info "# Elaborating. Log saved to xrun_elaborate.log"
  xrun -elaborate  -l xrun_elaborate.log $XRUN_ARGS
  xrun_check_status $? "Elaboration"
} #>>>
#------------------------------------------------------------------------------
function xrun_run_all_tests() { #<<<
  COV_TEST=""
  if [[ "$GUI" != "" ]] ; then
      if [[ "$RUN_IMC" != "" ]]; then
        COV_TEST="-covtest ${TESTS[0]}"
      fi
      xrun $XRUN_ARGS \
        $COV_TEST \
        -l xrun_gui.log
#        +UVM_TESTNAME=${TESTS[0]} \
  else  
    TEST_LIST=""

    for TEST in ${TESTS[@]} ; do
      TEST_LIST="$TEST_LIST $TEST"
      xrun_info "# Running test: $TEST. Log saved to xrun_test_$TEST.log"
      if [[ "$RUN_IMC" != "" ]]; then
        COV_TEST="-covtest $TEST"
      fi
      # run the simulation
      xrun $XRUN_ARGS \
        $COV_TEST \
        -l xrun_test_$TEST.log
#        +UVM_TESTNAME=$TEST \
      xrun_check_status $? "Test $TEST"
    done

    echo "# End of tests."
  fi
} #>>>
#------------------------------------------------------------------------------
function run_imc { #<<<
  xrun_info "# Running imc."
  #------------------------------------------------------------------------------
  # print the coverage results summary (non-GUI mode)
  if [[ "$GUI" == "" ]] ; then

    # merging the coverage results from different tests
    imc -nocopyright -batch -initcmd \
      "load -run $TEST; merge -out merged_results $TEST_LIST; exit" |& tee xrun_cov.rpt
    xrun_check_status $? "IMC MERGE"

    # printing the summary
    imc -nocopyright -batch -initcmd \
      "load -run merged_results; report -summary; exit" |& tee -a xrun_cov.rpt
    xrun_check_status $? "IMC REPORT"

    xrun_info "\
 The coverage report was saved to xrun_cov.rpt file.
 To browse the results with gui use:
   imc -load merged_results"
  fi
} #>>>
#------------------------------------------------------------------------------
# run the main
main

# vim: fdm=marker foldmarker=<<<\,>>>
