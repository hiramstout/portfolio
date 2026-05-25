function initializeFilesForNextLoop() {
    BASEMINDATE=$( date -v "+1d" -v "-7H" +'%Y-%m-%d' )
    BASEMAXDATE=$( date -v "+1d" -v "-7H" +'%Y-%m-%d' )
    DATEFORFILE=$( date +'%Y-%m-%d')
    TIMEFORFILE=$( date +'%I-%M %p')
    mkdir -p ~/Documents/Acuity-Data
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/decision-array-values
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/same-day-ids
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/same-day-ids/`echo -n $BASEMINDATE`
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/same-day-ids/`echo -n $SAMEDAY`
    cd ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE
    touch ./call-center-copy-appointments.csv
    touch ./old-clinic-copy-appointments.csv
    touch ./lookup-appointment-output.csv
    touch ./canceled-duplicates.csv
    touch ./new-clinic-copy-appointments.csv
    touch ./new-call-center-copy-appointments.csv
    touch ./new-clinic-canceled-appointments.csv
    touch ./new-phone-importer-appointments.csv
    touch ./changed-appointment-output.csv
    touch ./rescheduled-appointment-output.csv
    touch ./new-calendar-output.csv
    touch ./canceled-pi-appointments.csv
    touch ./same-day-ids/`echo -n $BASEMINDATE`/associated-ids.csv
    touch ./same-day-ids/`echo -n $BASEMINDATE`/ccc-app-type-ids.csv
    touch ./same-day-ids/`echo -n $BASEMINDATE`/cc-app-type-ids.csv
    touch ./decision-array-values/new-calendar-associated-ids.csv
    touch ./decision-array-values/appointment-mod-needed.csv
    touch ./decision-array-values/appointment-rsc-needed.csv
    touch ./decision-array-values/clinic-canceled-consult.csv
    touch ./decision-array-values/new-call-center-appointment-needed.csv
    touch ./decision-array-values/appointment-lookup-needed.csv
    touch ./decision-array-values/duplicates-queued-for-cancel-and-already-canceled.csv
    touch ./decision-array-values/pi-cc-id-output.csv
    touch ./decision-array-values/pi-appointment-needed.csv
    touch ./decision-array-values/pi-cancel-needed.csv
    touch ./decision-array-values/new-clinic-copy-appointment-needed.csv
    touch ./decision-array-values/empty-calendars.txt
    touch ./decision-array-values/debugging-data.txt
    touch ./clinic-show-rate-data.json
    touch ./appointment-show-rate-data.json
    touch ./commanderrors.txt
    touch ./tmp
    touch ./tmp2
    touch ./tmp3
}
function initializeShowrateFilesForNextLoop() {
    BASEMINDATE=$( date -v "+1d" -v "-7H" +'%Y-%m-%d' )
    BASEMAXDATE=$( date -v "+1d" -v "-7H" +'%Y-%m-%d' )
    DATEFORFILE=$( date +'%Y-%m-%d')
    TIMEFORFILE=$( date +'%I-%M %p')
    mkdir -p ~/Documents/Acuity-Data
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/showrates/decision-array-values
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/showrates/same-day-ids
    cd ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/showrates/
    touch ./call-center-copy-appointments.csv
    touch ./old-clinic-copy-appointments.csv
    touch ./canceled-duplicates.csv
    touch ./new-clinic-copy-appointments.csv
    touch ./new-call-center-copy-appointments.csv
    touch ./new-clinic-canceled-appointments.csv
    touch ./new-phone-importer-appointments.csv
    touch ./changed-appointment-output.csv
    touch ./rescheduled-appointment-output.csv
    touch ./new-calendar-output.csv
    touch ./canceled-pi-appointments.csv
    touch ./qa-and-mishandled-appointment-change-output.csv
    touch ./adjusted-same-day.csv
    touch ./same-day-lookup-appointment-output.csv
    touch ./decision-array-values/new-calendar-associated-ids.csv
    touch ./decision-array-values/appointment-mod-needed.csv
    touch ./decision-array-values/appointment-rsc-needed.csv
    touch ./decision-array-values/clinic-canceled-consult.csv
    touch ./decision-array-values/new-call-center-appointment-needed.csv
    touch ./decision-array-values/appointment-lookup-needed.csv
    touch ./decision-array-values/duplicates-queued-for-cancel-and-already-canceled.csv
    touch ./decision-array-values/pi-cc-id-output.csv
    touch ./decision-array-values/pi-appointment-needed.csv
    touch ./decision-array-values/pi-cancel-needed.csv
    touch ./decision-array-values/new-clinic-copy-appointment-needed.csv
    touch ./decision-array-values/empty-calendars.txt
    touch ./decision-array-values/debugging-data.txt
    touch ./clinic-show-rate-data.json
    touch ./appointment-show-rate-data.json
    touch ./commanderrors.txt
    touch ./tmp
    touch ./tmp2
    touch ./tmp3
}
function initializePreviousShowrateFilesForNextLoop() {
    DATEFORFILE=$( date +'%Y-%m-%d')
    TIMEFORFILE=$( date +'%I-%M %p')
    mkdir -p ~/Documents/Acuity-Data
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/previous-showrates/decision-array-values
    mkdir -p ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/previous-showrates/same-day-ids
    cd ~/Documents/Acuity-Data/$DATEFORFILE/$TIMEFORFILE/previous-showrates/
    touch ./call-center-copy-appointments.csv
    touch ./old-clinic-copy-appointments.csv
    touch ./canceled-duplicates.csv
    touch ./new-clinic-copy-appointments.csv
    touch ./new-call-center-copy-appointments.csv
    touch ./new-clinic-canceled-appointments.csv
    touch ./new-phone-importer-appointments.csv
    touch ./changed-appointment-output.csv
    touch ./rescheduled-appointment-output.csv
    touch ./new-calendar-output.csv
    touch ./canceled-pi-appointments.csv
    touch ./qa-and-mishandled-appointment-change-output.csv
    touch ./adjusted-same-day.csv
    touch ./same-day-lookup-appointment-output.csv
    touch ./decision-array-values/new-calendar-associated-ids.csv
    touch ./decision-array-values/appointment-mod-needed.csv
    touch ./decision-array-values/appointment-rsc-needed.csv
    touch ./decision-array-values/clinic-canceled-consult.csv
    touch ./decision-array-values/new-call-center-appointment-needed.csv
    touch ./decision-array-values/appointment-lookup-needed.csv
    touch ./decision-array-values/duplicates-queued-for-cancel-and-already-canceled.csv
    touch ./decision-array-values/pi-cc-id-output.csv
    touch ./decision-array-values/pi-appointment-needed.csv
    touch ./decision-array-values/pi-cancel-needed.csv
    touch ./decision-array-values/new-clinic-copy-appointment-needed.csv
    touch ./decision-array-values/empty-calendars.txt
    touch ./decision-array-values/debugging-data.txt
    touch ./clinic-show-rate-data.json
    touch ./appointment-show-rate-data.json
    touch ./commanderrors.txt
    touch ./tmp
    touch ./tmp2
    touch ./tmp3
}
function clearPersistentVars() {
    appointmentModNeeded=(  )
    newAppointmentAssociatedIDs=(  )
    clinicCanceledConsults=(  )
    newCallCenterAppointmentNeeded=(  )
    ccIDs=(  )
    cccIDs=(  )
    piCCids=(  )
    piAssociatedCCids=(  )
    appointmentLookupNeeded=(  )
    modNeededDescriptor=(  )
    newClinicCopyAppointmentNeeded=(  )
    appointmentRSCneeded=(  )
    preferredDuplicateAppIDs=(  )
    duplicateArray=(  )
    canceledDuplicates=(  )
    piAppointmentNeeded=(  )
    invertedPIassociatedCCids=(  )
    persistentAppDates=(  )
    persistentAppTypeNames=(  )
    persistentAppTypeIDs=(  )
    persistentAppStartTimes=(  )
    persistentCalNames=(  )
    persistentCalIDs=(  )
    persistentCanceledStatuses=(  )
    persistentDatetimes=(  )
    persistentDatetimesCreated=(  )
    persistentAppEndTimes=(  )
    persistentFirstNames=(  )
    persistentLabelArray=(  )
    persistentLastNames=(  )
    persistentNotes=(  )
    persistentPhoneNumbers=(  )
    persistentTimeZones=(  )
    persistentUnixCreatedTimes=(  )
    persistentUnixTimes=(  )
    persistentCalGroups=(  )
    piDuplicateCounter=(  )
    sameDayClinicShowsCount=( )
    sameDayTotalAppsCount=( )
    sameDayUntaggedCount=( )
    sameDayNSincorrectCount=( )
    sameDayRescheduledCount=( )
    sameDayCallCenterCanceledCount=( )
    sameDayClinicCanceledCount=( )
    sameDayUntaggedAppIDs=( )
    sameDayNSincorrectAppIDs=( )
    sameDayRescheduledAppIDs=( )
    sameDayCallCenterCanceledAppIDs=( )
    sameDayClinicCanceledAppIDs=( )
    sameDayClinicShowsAppIDs=( )
    sameDayUntaggedAppIDs=( )
    sameDayNSincorrectAppIDs=( )
    sameDayRescheduledAppIDs=( )
    sameDayCallCenterCanceledAppIDs=( )
    sameDayClinicCanceledAppIDs=( )
    sameDayLookupNeeded=(  )
    sameDayGrandTotalCount=( )
    sameDayGrandTotalAppIDs=(  )
    parameterNames=( )
    argMapper=(  )
    piArgMapper=(  )
}
function setupDecisionArrayOutputFile() {
    echo -n '' > tmp
    for (( interval=2; interval<=$#; interval+=1 )) do
        echo $( eval "echo -n \$$interval" ) >> tmp
    done
    sed 'H;1h;$!d;x;y/\n/,/' tmp > ./decision-array-values/$1
}
function setupStandardResultCSVheadings() {
    echo -n '' > tmp
    for field in ${FIELDS[@]}; do echo $field; done >> tmp
    for (( interval = 2; interval <= $#; interval+=1 )) do
        echo $( eval "echo -n \$$interval" ) >> tmp
    done
    sed 'H;1h;$!d;x;y/\n/,/' tmp > $1
}
function setupAssociatedIDsArray() {

    associatedIDs=( )
    invertedAssociatedIDs=( )
    sameDayAssociatedIDs=( )
    sameDayInvertedAssociatedIDs=( )
    sameDayCCCappTypeIDs=( )
    sameDayCCappTypeIDs=( )
    importAssociatedIDs=( )
    importSameDayAssociatedIDs=( )
    importSameDayCCCappTypeIDs=( )
    importSameDayCCappTypeIDs=( )
    scp -q -i ~/.private/tmp-file-service-key file-service@server.edmedicalclinic.com:/Users/file-service/Documents/associated-ids.csv ~/.private/calendar-associated-ids.csv

    IFS=$'\n'
    importAssociatedIDs=( $( cat ~/.private/calendar-associated-ids.csv | grep -E '^[0-9]*,[0-9]*' ) )
    
    IFS=','
    for unparsedIDs in $importAssociatedIDs; do
        ids=( $( echo -n $unparsedIDs ) ); cccID=${ids[1]}; ccID=${ids[2]}
        if [[ ! $associatedIDs[$cccID] && ! $invertedAssociatedIDs[$ccID] ]]
            then associatedIDs+=( [$cccID]=$ccID ); invertedAssociatedIDs+=( [$ccID]=$cccID )
        else
            if [[ "$cccID" && "${associatedIDs[$cccID]}" ]]
                then cat ~/.private/calendar-associated-ids.csv | grep -v $ccID > tmp2; cat tmp2 > ~/.private/calendar-associated-ids.csv
            elif [[ "$ccID" && "${invertedAssociatedIDs[$ccID]}" ]]
                then cat ~/.private/calendar-associated-ids.csv | grep -v $cccID > tmp2; cat tmp2 > ~/.private/calendar-associated-ids.csv
            fi
        fi
    done
    IFS=$'\n'
    
    if [[ $sourceFunction != "previous-showrates" ]]; then
        scp -q -r -i ~/.private/tmp-file-service-key file-service@server.edmedicalclinic.com:/Users/file-service/Documents/same-day-associated-ids/`echo -n $SAMEDAY` ./same-day-ids/
        
        importSameDayAssociatedIDs=( $( cat ./same-day-ids/`echo -n $SAMEDAY`/associated-ids.csv | grep -E '^[0-9]*,[0-9]*$' ) )
        importSameDayCCCappTypeIDs=( $( cat ./same-day-ids/`echo -n $SAMEDAY`/ccc-app-type-ids.csv | grep -E '^[0-9]*,[0-9]*$' ) )
        importSameDayCCappTypeIDs=( $( cat -vet ./same-day-ids/`echo -n $SAMEDAY`/cc-app-type-ids.csv | grep -E '^[0-9]*,[0-9]*' | tr -d '^M' | tr -d '$' ) )
        
        IFS=','
        for unparsedIDs in $importSameDayAssociatedIDs; do
            ids=( $( echo -n $unparsedIDs )  ); sameDayAssociatedIDs+=( ["${ids[1]}"]="${ids[2]}" ); sameDayInvertedAssociatedIDs+=( ["${ids[2]}"]="${ids[1]}" )
        done
        
        for unparsedIDs in $importSameDayCCCappTypeIDs; do
            ids=( $( echo -n $unparsedIDs ) ); sameDayCCCappTypeIDs+=( ["${ids[1]}"]="${ids[2]}" )
        done
        
        for unparsedIDs in $importSameDayCCappTypeIDs; do
            ids=( $( echo -n $unparsedIDs ) ); sameDayCCappTypeIDs+=( ["${ids[1]}"]="${ids[2]}" )
        done
    fi
    
    IFS=$'\n'
    
    importAssociatedIDs=(  )
    importSameDayAssociatedIDs=(  )
    importSameDayCCCappTypeIDs=(  )
    importSameDayCCappTypeIDs=(  )
}

function parsePreviousDayIDs() {

    sameDayAssociatedIDs=( )
    sameDayInvertedAssociatedIDs=( )
    sameDayCCCappTypeIDs=( )
    sameDayCCappTypeIDs=( )
    importAssociatedIDs=( )
    importSameDayAssociatedIDs=( )
    importSameDayCCCappTypeIDs=( )
    importSameDayCCappTypeIDs=( )

    mkdir -p ./same-day-ids/`echo -n $SAMEDAY`

    scp -q -r -i ~/.private/tmp-file-service-key file-service@server.edmedicalclinic.com:/Users/file-service/Documents/same-day-associated-ids/`echo -n $SAMEDAY` ./same-day-ids/
    
    importSameDayAssociatedIDs=( $( cat ./same-day-ids/`echo -n $SAMEDAY`/associated-ids.csv | grep -E '^[0-9]*,[0-9]*$' ) )
    importSameDayCCCappTypeIDs=( $( cat ./same-day-ids/`echo -n $SAMEDAY`/ccc-app-type-ids.csv | grep -E '^[0-9]*,[0-9]*$' ) )
    importSameDayCCappTypeIDs=( $( cat -vet ./same-day-ids/`echo -n $SAMEDAY`/cc-app-type-ids.csv | grep -E '^[0-9]*,[0-9]*' | tr -d '^M' | tr -d '$' ) )
    
    IFS=','
    for unparsedIDs in $importSameDayAssociatedIDs; do
        ids=( $( echo -n $unparsedIDs )  ); sameDayAssociatedIDs+=( ["${ids[1]}"]="${ids[2]}" ); sameDayInvertedAssociatedIDs+=( ["${ids[2]}"]="${ids[1]}" )
    done
    
    for unparsedIDs in $importSameDayCCCappTypeIDs; do
        ids=( $( echo -n $unparsedIDs ) ); sameDayCCCappTypeIDs+=( ["${ids[1]}"]="${ids[2]}" )
    done
    
    for unparsedIDs in $importSameDayCCappTypeIDs; do
        ids=( $( echo -n $unparsedIDs ) ); sameDayCCappTypeIDs+=( ["${ids[1]}"]="${ids[2]}" )
    done
    IFS='\n'
}

function acuityCommand() {

    parameterNames=( )
    local commandNameLocal=''
    local stringPreference=''
    local uniLocal=''
    local phone='false'
    local singleArgs=(  )
    local jsonVars=(  )

    while (( $# )) do
        case $1 in
            --command-name) local commandNameLocal=$2; shift; shift;;
            --string-only) local stringPreference="true"; shift;;
            --uni-id) uniLocal=$2; parameterNames+=( 'id' ); locValueid=$2; shift; shift;;
            --phone) local phone='true'; shift;;
            --json) jsonVars=( $2 ); shift; shift;;
            --*) parameterNames+=( $( echo -n $1 | sed 's/--//g' ) ); local locValue`echo -n $1 | sed 's/--//g'`="$( echo -n $2 | sed 's_[\][\]*_\\\\_g; s_~"_\\\\"_g; s_[\$`"]_\\&_g' )"; shift; shift;; # maybe 4
            [^-][^-]*) singleArgs+=( $1 ); shift;;
        esac
    done
    
    set -- "${POSITIONAL_ARGS[@]}"
    
    local json=''
    for var in $jsonVars; do
        json=''
    done
    
    if [[ "$uniLocal" ]]; then
        buildSingleUniversalVariables $uniLocal
        for varName in "${uniVarNames[@]}"; do
            if [[ $varName == 'uni''PhoneNumber' ]]; then
                if $( echo -n "$phone" );
                    then local locValue`echo -n $varName`='\"phone\": \"'$( eval "echo -n \$$varName" )'\",'; parameterNames+=( "uniPhoneNumber" )
                    else local locValue`echo -n $varName`=""; parameterNames+=( "uniPhoneNumber" )
                fi
            elif (( ${parameterNames[(ie)$varName]} > ${#parameterNames} ))
                then local locValue`echo -n $varName`=$( eval "echo -n \$$varName | sed '"'s_[\]\([\]\)*_\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_g; s_[\$`"]_\\&_g'"'" ); parameterNames+=( "$varName" ) #needs same number as lookup loop
                #Currently working for new appointments ^ with non data-string
            fi
        done
    fi
    
    commandStringLocal=$commandStringArray[$commandNameLocal]
    for parameter in $parameterNames; do
        commandStringLocal=$( echo -n $commandStringLocal | sed 's/\$'$parameter'/'"$( eval "echo -n \$locValue$parameter" | sed ' s_\\_\\\\\\\\_g; s_[]$`"!&.*^/|[-]_\\&_g' )"'/g' ) #s_\\\\"_\\"_g;
    done
    
    if [[ "$stringPreference" == "true" ]];
        then echo "$commandStringLocal | json_pp | sed ""'"'s/\\\\r//g; s_\\/_/_g; s/\\/\\\\\\\\/g'\'
        else eval $( echo -n "$commandStringLocal" ) | json_pp | sed 's/\\r//g; s_\\/_/_g; s/\\/\\\\\\\\/g'
    fi
}
function buildStandardResultArrays() {
#    IFS=$'\n'
#    while (( $# )) do
#        case $1 in
#            --results) local commandNameLocal=$2; shift; shift;;
#            *) shift;;
#        esac
#    done
#    set -- "${POSITIONAL_ARGS[@]}"

    echo '' > tmp2
    for datatype in $DATATYPES; do echo $1 | grep -E "$datatype" >> tmp2; done
    appTypeIDs=( $( cat tmp2 | grep ${SEARCHEXP[1]} | sed "s/[^0-9]//g; s/34371433/12794227/g" ) ) # converts facebook ads to regular consults
    calNames=( $( cat tmp2 | grep ${SEARCHEXP[2]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]"//g; s/",//g' ) )
    canceledStatuses=( $( cat tmp2 | grep ${SEARCHEXP[3]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]//g; s/,//g' ) )
    appDates=( $( cat tmp2 | grep ${SEARCHEXP[4]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]"//g; s/",//g' ) )
    datetimesCreated=( $( cat tmp2 | grep ${SEARCHEXP[5]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]"//g; s/",//g' ) )
    appEndTimes=( $( cat tmp2 | grep ${SEARCHEXP[6]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]"//g; s/",//g' ) )
    firstNames=( $( cat tmp2 | grep ${SEARCHEXP[7]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]//g; s/^"",$/Left Blank/g; s/^"//g; s/",$//g; s/"//g; s/\\//g' ) )
    ids=( $( cat tmp2 | grep ${SEARCHEXP[8]} | sed "s/[^0-9]//g" ) )
    lastNames=( $( cat tmp2 | grep ${SEARCHEXP[9]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]//g; s/^"",$/Left Blank/g; s/^"//g; s/",$//g; s/"//g; s/\\//g' ) )
    notes=( $( cat tmp2 | grep ${SEARCHEXP[10]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]//g; s/^"",$/Left Blank/g; s/^"//g; s/",$//g; s/\([\]*"\)/"/g' ) )
    phoneNumbers=( $(  cat tmp2 | grep ${SEARCHEXP[11]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]//g; s/^"",$/Left Blank/g; s/^"//g; s/",$//g; s/"//g; s/\\//g' ) )
    appStartTimes=( $( cat tmp2 | grep ${SEARCHEXP[12]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]"//g; s/",//g' ) )
    appTypeNames=( $( cat tmp2 | grep ${SEARCHEXP[13]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]"//g; s/"//g' ) )
    datetimes=( $( cat tmp2 | grep ${SEARCHEXP[14]} | sed 's/\([[:space:]]\)*"[A-Za-z]*"[[:space:]]:[[:space:]]"//g; s/",//g' ) )
    calIDs=( $(  cat tmp2 | grep ${SEARCHEXP[15]} | sed 's/[^0-9]//g' ) )
}
function parseResultsForOutput() {
    
    max=$#
    local commandStringLocal=''
    local commandResultsLocal=''
    local errorMessageLocal=''
    local outputFileLocal=''
    local primaryIDlocal=''
    local associatedIDlocal=''
    local associativeVarNames=(  )
    local iterativeVarNames=(  )
    local staticVarNames=(  )
    local staticErrorVarValues=(  )
    local staticErrorVarNames=(  )
    local singleArgs=( )
    
    while (( $# )) do
        case $1 in
            --command) commandStringLocal=$2; shift; shift;;
            --result) commandResultsLocal=$2; shift; shift;;
            --output) outputFileLocal=$2; shift; shift;;
            --error) errorMessageLocal=$2; shift; shift;;
            --id) primaryIDlocal=$2; shift; shift;;
            --aid) associatedIDlocal=$2; shift; shift;;
            -A) associativeVarNames+=( $2 ); shift; shift;;
            -I) iterativeVarNames+=( $2 ); shift; shift;;
            -S) staticVarNames+=( $2 ); shift; shift;;
            -E) staticErrorVarValues+=( $2 ); shift; shift;;
            -ES) staticErrorVarNames+=( $2 ); shift; shift;;
            *) singleArgs+=( $1 ); shift;;
        esac
    done

    set -- "${POSITIONAL_ARGS[@]}"
    
    for datatype in $DATATYPES; do echo $commandResultsLocal | grep -E "$datatype"; echo -n '\n'; done > tmp2
    
    #First if statement would only apply to lookup loop
    
    if [[ $( echo $commandResultsLocal | grep '"status_code" : 404' ) ]]; then
        echo $'\n'$errorbar"\n$errorMessageLocal"$'\n'$errorbar$'\n' >> commanderrors.txt
        echo "UNFOUND ASSOCIATED ID LOOKUP - MISSING $calGroup APPOINTMENT"$'\n'$errorbar$'\n' >> commanderrors.txt
        echo "Found appointment ID: $primaryIDlocal\nUnfound appointment ID: $associatedIDlocal\nFound appointment notes: ${persistentNotes[$primaryIDlocal]}\n"$commandResultsLocal >> commanderrors.txt
    elif [[ $( echo $commandResultsLocal | grep '"status_code"' ) && $( echo $commandResultsLocal | grep -E "[[:space:]]4[0-9]{2}" ) ]]; then
        echo "\n$errorMessageLocal"$'\n''--------------------------' >> commanderrors.txt
        echo $commandStringLocal >> commanderrors.txt
        for var in $staticErrorVarValues; do eval "echo $var >> commanderrors.txt"; done
        for var in $staticErrorVarNames; do eval "echo $var: \$( eval \"echo -n \$$var\" ) >> commanderrors.txt"; done
        
        echo $commandResultsLocal >> commanderrors.txt
    elif [[ $( echo $commandResultsLocal | grep '"id" : ' ) ]]; then
        for (( functionInt = 1; functionInt <= ${#ids[@]}; functionInt+=1 )) do
            echo -n '' > tmp3
            echo $appTypeIDs[$functionInt] >> tmp3
            echo $calNames[$functionInt] >> tmp3
            echo $canceledStatuses[$functionInt] >> tmp3
            echo $appDates[$functionInt] >> tmp3
            echo $datetimesCreated[$functionInt] >> tmp3
            echo $appEndTimes[$functionInt] >> tmp3
            echo $firstNames[$functionInt] >> tmp3
            echo $ids[$functionInt] >> tmp3
            echo $lastNames[$functionInt] >> tmp3
            echo $notes[$functionInt] >> tmp3
            echo $phoneNumbers[$functionInt] >> tmp3
            echo $appStartTimes[$functionInt] >> tmp3
            echo $appTypeNames[$functionInt] >> tmp3
            echo $datetimes[$functionInt] >> tmp3
            echo $calIDs[$functionInt] >> tmp3

            for var in $associativeVarNames; do eval 'echo "${'"$var"'['"${ids[$functionInt]}"']}"' >> tmp3; done
            for var in $iterativeVarNames; do eval 'echo "${'"$var"'['"$functionInt"']}"' >> tmp3; done
            for var in $staticVarNames; do eval "echo \"\$$var\" >> tmp3"; done
            
            sed 's/,//g; H;1h;$!d;x;y/\n/,/; s/\$//g' tmp3 >> $outputFileLocal
        done
    elif [[ $commandResultsLocal == '[]' ]]; then
        echo "${commandStringLocal}\nMINDATE: $MINDATE, MAXDATE: $MAXDATE" >> ./decision-array-values/empty-calendars.txt
    else
        echo "\n$errorbar\nNO PARSABLE COMMAND RESULTS - $errorMessageLocal"$'\n'$errorbar\
        $'\n'"Command String: \n"$commandStringLocal$'\n'"Command Results: \n"$commandResultsLocal >> commanderrors.txt
    fi
}
function buildPersistentArrays() {
    i=1
    for idIter in $ids; do
        persistentAppDates+=( [$( echo -n $idIter )]=$appDates[$i] )
        persistentAppTypeNames+=( [$( echo -n $idIter )]="${appTypeNames[$i]}" )
        persistentAppTypeIDs+=( [$( echo -n $idIter )]=$appTypeIDs[$i] )
        persistentAppStartTimes+=( [$( echo -n $idIter )]=$appStartTimes[$i] )
        persistentCalNames+=( [$( echo -n $idIter )]="${calNames[$i]}" )
        persistentCalIDs+=( [$( echo -n $idIter )]=$calIDs[$i] )
        persistentCanceledStatuses+=( [$( echo -n $idIter )]=$canceledStatuses[$i] )
        persistentDatetimes+=( [$( echo -n $idIter )]=$datetimes[$i] )
        persistentDatetimesCreated+=( [$( echo -n $idIter )]=$datetimesCreated[$i] )
        persistentAppEndTimes+=( [$( echo -n $idIter )]=$appEndTimes[$i] )
        persistentFirstNames+=( [$( echo -n $idIter )]="$( echo -n "${firstNames[$i]}" | sed 's_\\_\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_g' )" )
        persistentLastNames+=( [$( echo -n $idIter )]="$( echo -n "${lastNames[$i]}" | sed 's_\\_\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_g' )" )
        persistentNotes+=( [$( echo -n $idIter )]="$( echo -n "${notes[$i]}" | sed 's_\\_\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_g' )" )
        persistentPhoneNumbers+=( [$( echo -n $idIter )]="$( echo -n "${phoneNumbers[$i]}" | sed 's_\\_\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_g' )" )
        persistentTimeZones+=( [$( echo -n $idIter )]=$( echo -n $datetimes[$i] | sed 's/[0-9]*-[0-9]*-[0-9:T]*-//g' ) )
        labelSearch=$( echo $commandResults | grep -5 $idIter | grep -E $LABELDATATYPE )
        if [[ $labelSearch ]]; then persistentLabelArray+=( [$( echo -n $idIter )]=$( echo $labelSearch | sed "s/[^0-9]//g" ) ); fi
        persistentUnixTimes+=( [$( echo -n $idIter )]=$( date -j -f "%Y-%m-%dT%H:%M:%S%z" "${datetimes[$i]}" +"%s" ) )
        persistentUnixCreatedTimes+=( [$( echo -n $idIter )]=$( date -j -f "%Y-%m-%dT%H:%M:%S%z" "${datetimesCreated[$i]}" +"%s" ) )
        uniqueID=$( echo -n "${firstNames[$i]}${lastNames[$i]}${callCenterCalIDs[$interval]}$MINDATE$( if (( $# )); then eval 'echo -n $1'; fi )" | sed 's/-//g' )
        persistentUniqueIDs+=( [$( echo -n ${(L)uniqueID} )]=$idIter )
        persistentInvertedUniqueIDs+=( [$( echo -n $idIter)]=${(L)uniqueID} )
        persistentCalGroups+=( [$( echo -n $idIter )]=$1 )
        i=$(( $i + 1 ))
    done
}
function buildSingleCallCenterVariables() {
    local cccID=$1
    cccAppDate=$persistentAppDates[$cccID]
    cccAppTypeName=$persistentAppTypeNames[$cccID]
    cccAppTypeID=$persistentAppTypeIDs[$cccID]
    cccAppStartTime=$persistentAppStartTimes[$cccID]
    cccCalName=$persistentCalNames[$cccID]
    cccCalID=$persistentCalIDs[$cccID]
    cccCanceledStatus=$persistentCanceledStatuses[$cccID]
    cccDatetime=$persistentDatetimes[$cccID]
    cccDatetimeCreated=$persistentDatetimesCreated[$cccID]
    cccAppEndTime=$persistentAppEndTimes[$cccID]
    cccFirstName="$( echo -n "${persistentFirstNames[$cccID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    cccLabelID=$persistentLabelArray[$cccID]
    cccLastName="$( echo -n "${persistentLastNames[$cccID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    cccNote="$( echo -n "${persistentNotes[$cccID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    cccPhoneNumber="$( echo -n "${persistentPhoneNumbers[$cccID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    cccTimeZone=$persistentTimeZones[$cccID]
    cccAppointmentUnixTime=$persistentUnixTimes[$cccID]
    cccScheduledUnixTime=$persistentUnixCreatedTimes[$cccID]
    cccUniqueID=$persistentInvertedUniqueIDs[$cccID]
}
function buildSingleClinicCopyVariables() {
    local ccID=$1
    ccAppDate=$persistentAppDates[$ccID]
    ccAppTypeName=$persistentAppTypeNames[$ccID]
    ccAppTypeID=$persistentAppTypeIDs[$ccID]
    ccAppStartTime=$persistentAppStartTimes[$ccID]
    ccCalName=$persistentCalNames[$ccID]
    ccCalID=$persistentCalIDs[$ccID]
    ccCanceledStatus=$persistentCanceledStatuses[$ccID]
    ccDatetime=$persistentDatetimes[$ccID]
    ccDatetimeCreated=$persistentDatetimesCreated[$ccID]
    ccAppEndTime=$persistentAppEndTimes[$ccID]
    ccFirstName="$( echo -n "${persistentFirstNames[$ccID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    ccLabelID=$persistentLabelArray[$ccID]
    ccLastName="$( echo -n "${persistentLastNames[$ccID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    ccNote="$( echo -n "${persistentNotes[$ccID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    ccPhoneNumber="$( echo -n "${persistentPhoneNumbers[$ccID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    ccTimeZone=$persistentTimeZones[$ccID]
    ccAppointmentUnixTime=$persistentUnixTimes[$ccID]
    ccScheduledUnixTime=$persistentUnixCreatedTimes[$ccID]
    ccUniqueID=$persistentInvertedUniqueIDs[$ccID]
}
function buildSingleUniversalVariables() {
    local uniID=$1
    uniAppDate=$persistentAppDates[$uniID]
    uniAppTypeName=$persistentAppTypeNames[$uniID]
    uniAppTypeID=$persistentAppTypeIDs[$uniID]
    uniAppStartTime=$persistentAppStartTimes[$uniID]
    uniCalName=$persistentCalNames[$uniID]
    uniCalID=$persistentCalIDs[$uniID]
    uniCanceledStatus=$persistentCanceledStatuses[$uniID]
    uniDatetime=$persistentDatetimes[$uniID]
    uniDatetimeCreated=$persistentDatetimesCreated[$uniID]
    uniAppEndTime=$persistentAppEndTimes[$uniID]
    uniFirstName="$( echo -n "${persistentFirstNames[$uniID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    uniLabelID=$persistentLabelArray[$uniID]
    uniLastName="$( echo -n "${persistentLastNames[$uniID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    uniNote="$( echo -n "${persistentNotes[$uniID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    uniPhoneNumber="$( echo -n "${persistentPhoneNumbers[$uniID]}" | sed 's_\\_\\\\\\\\\\\\\\\\_g' )"
    uniTimeZone=$persistentTimeZones[$uniID]
    uniAppointmentUnixTime=$persistentUnixTimes[$uniID]
    uniScheduledUnixTime=$persistentUnixCreatedTimes[$uniID]
    uniUniqueID=$persistentInvertedUniqueIDs[$uniID]
    uniCalGroup=$persistentCalGroups[$uniID]
}



function checkArraySizes() {
    if [[ ${#appTypeIDs[@]} != ${#calNames[@]} || ${#calNames[@]} != ${#canceledStatuses[@]} || ${#canceledStatuses[@]} != ${#appDates[@]} || ${#appDates[@]} != ${#datetimesCreated[@]} || ${#datetimesCreated[@]} != ${#appEndTimes[@]} || ${#appEndTimes[@]} != ${#firstNames[@]} || ${#firstNames[@]} != ${#ids[@]} || ${#ids[@]} != ${#lastNames[@]} || ${#lastNames[@]} != ${#notes[@]} || ${#notes[@]} != ${#phoneNumbers[@]} || ${#phoneNumbers[@]} != ${#appStartTimes[@]} || ${#appStartTimes[@]} != ${#appTypeNames[@]} || ${#appTypeNames[@]} != ${#datetimes[@]} || ${#datetimes[@]} != ${#calIDs[@]} ]]
    then
        echo "ARRAY SIZES ARE NOT EQUAL. ABORTING OPERATION, ALL OPERATIONS DONE SO FAR HAVE BEEN SAVED ARRAY SIZES ARE NOT EQUAL.\nappTypeIDs Array Size: ${#appTypeIDs[@]} \ncalNames Array Size: ${#calNames[@]} \ncanceledStatuses Array Size: ${#canceledStatuses[@]} \nappDates Array Size: ${#appDates[@]} \ndatetimesCreated Array Size: ${#datetimesCreated[@]} \ndatetimes Array Size: ${#datetimes[@]} \nappEndTimes Array Size: ${#appEndTimes[@]} \nfirstNames Array Size: ${#firstNames[@]} \nids Array Size: ${#ids[@]} \nlastNames Array Size: ${#lastNames[@]} \nnotes Array Size: ${#notes[@]} \nphoneNumbers Array Size: ${#phoneNumbers[@]} \nappStartTimes Array Size: ${#appStartTimes[@]} \nappTypeNames Array Size: ${#appTypeNames[@]}\ncalIDs Array Size: ${#calIDs[@]} \n"
        echo "$1 - ARRAYEXCEPTION"$'\n''--------------------------' >> commanderrors.txt
        echo $commandResults >> commanderrors.txt
        throw ARRAYEXCEPTION
    fi
}
function checkTakeOver() {
    scp -q -i  ~/.private/tmp-file-service-key file-service@server.edmedicalclinic.com:/Users/file-service/Documents/current-user ~/.private/current-user
    currentUserInfo=( $( cat ~/.private/current-user ) )
    if [[ $currentUserInfo[3] != $SCRIPTKEY ]]; then
        echo "User ${currentUserInfo[1]} on computer ${currentUserInfo[2]} is taking control of the next day script. Terminating script now"
        throw TAKEOVER
    fi
}
function checkForLogicMapProceed() {
    if [[ $1 == '[]' || $( echo $1 | grep '"status_code" : 4' ) || ! $( echo $1 | grep '"id" : ' ) ]]; then echo -n false; else echo -n true; fi
}
function checkClinicCreatedConsult() {
    commandString="curl -s -X GET -H \"Accept: application/json\" -u 24765189:8ed5e713075e8d5e598daf1829860fd5 https://acuityscheduling.com/api/v1/appointments/$1 | json_pp"
    if [[ $( eval $commandString | grep "scheduledBy" | grep "hiram" ) == "" ]]; then echo true; else echo false; fi
}
function postToQA() {
    buildSingleClinicCopyVariables $1
    echo $'\n''-----------------------------'$'\n''QA REQUEST'$'\n''-----------------------------'$'\n'$4$'\n''-----------------------------'$'\n' >> commanderrors.txt
    echo "Appointment ID: $1\nCalendar Group: $2" >> commanderrors.txt
    subCommandString=$( acuityCommand --command-name post-to-qa --uni-id "$( echo -n $1 )" --requestType "$( echo -n $3 )" --string-only )
    subCommandResults=$( acuityCommand --command-name post-to-qa --uni-id "$( echo -n $1 )" --requestType "$( echo -n $3 )" )
    echo $subCommandString >> commanderrors.txt
    echo $subCommandResults >> commanderrors.txt
}
function checkAssociatedIDsSize() {
    scp -q -i  ~/.private/tmp-file-service-key file-service@server.edmedicalclinic.com:/Users/file-service/Documents/associated-ids-size ~/.private/calendar-associated-ids-size
    currentSize=$( ls -l ~/.private | grep calendar-associated-ids.csv | sed 's/ /\n/g' | grep -E "[0-9]{3}[0-9]*" )
    listedSize=$( cat ~/.private/calendar-associated-ids-size )
    if (( $currentSize > $(( $listedSize * 0.98 )) )); then
        echo -n true
        echo $currentSize > ~/.private/calendar-associated-ids-size
        scp -q -i  ~/.private/tmp-file-service-key ~/.private/calendar-associated-ids.csv file-service@server.edmedicalclinic.com:/Users/file-service/Documents/associated-ids.csv
        scp -q -i  ~/.private/tmp-file-service-key ~/.private/calendar-associated-ids-size file-service@server.edmedicalclinic.com:/Users/file-service/Documents/associated-ids-size
    else
        scp -q -i  ~/.private/tmp-file-service-key ~/.private/calendar-associated-ids.csv file-service@server.edmedicalclinic.com:/Users/file-service/Documents/associated-ids-archive-"$( date "+%Y-%m-%d %H-%m" )".csv
        scp -q -i ~/.private/tmp-file-service-key file-service@server.edmedicalclinic.com:/Users/file-service/Documents/associated-ids.csv ~/.private/calendar-associated-ids.csv
        echo -n true
        echo "Current Size: $currentSize\nListed Size: $listedSize" >> tmp
    fi
}



function buildModificationNeededDescriptor() {
    descriptor=$1
    buildSingleCallCenterVariables $2
    buildSingleClinicCopyVariables $3
    
    if [[ "$cccCalID" != "${clinicToCallCenterCalAssociater[$ccCalID]}" ]]; then descriptor+='CalID '; fi
    if [[ $cccAppStartTime != $ccAppStartTime ]]; then descriptor+='appStartTime '; fi
    if [[ $cccAppDate != $ccAppDate ]]; then descriptor+='appDate '; fi
    if [[ $cccFirstName != $ccFirstName ]]; then descriptor+='firstName '; fi
    if [[ $cccLastName != $ccLastName ]]; then descriptor+='lastName '; fi
    if [[ $cccCanceledStatus == true ]]; then descriptor+='canceled '; fi
    if [[ $cccNote != $ccNote ]]; then descriptor+='notes '; fi
    if (( $cccAppTypeID != $ccAppTypeID && $cccAppTypeID != 29284618 )); then descriptor+='alreadyCanceled '; fi
    if (( $cccAppTypeID != $ccAppTypeID  &&  $cccAppTypeID == 29284618 )); then descriptor+='plannedCancel '; fi
    modNeededDescriptor+=( [$( echo -n $3 )]="\"$descriptor\"" )
}
function checkForNeededModifications() {

    buildSingleCallCenterVariables $1
    buildSingleClinicCopyVariables $2

    if (( $cccAppTypeID == 13533391 )); then
        curl -s -X PUT -H "Content-Type: application/json" -d "{\"appointmentTypeID\": 12794227}" -H "Accept: application/json"  -u 24765189:8ed5e713075e8d5e598daf1829860fd5 https://acuityscheduling.com/api/v1/appointments/$cccID\?admin=true
        persistentAppTypeIDs[$1]=12794227
    fi
    
    if (( $cccLabelID == 7732202 )); then persistentAppTypeIDs[$1]=29284618; fi
    if [[ $cccCanceledStatus == true ]]; then persistentAppTypeIDs[$1]=29285605; fi
    
    cccAppTypeID=$persistentAppTypeIDs[$1]
    
    if (( $cccAppTypeID != 29284618 && $cccAppTypeID != 29285605 && $cccAppTypeID != 29423419 )); then persistentAppTypeIDs[$1]=12794227; fi
    
    cccAppTypeID=$persistentAppTypeIDs[$1]
    
    if [[ $cccAppTypeID == 29423419 ]]; then
    elif [[ $ccCanceledStatus == true && $cccCanceledStatus == false ]]; then
        clinicCanceledConsults+=( $cccID ) # Add function to change associated app ID
    elif (( $cccAppTypeID == 29284618 || $cccAppTypeID == 29285605 )); then
        if (( $cccAppTypeID != $ccAppTypeID )); then
            appointmentModNeeded+=( $2 )
            descriptorBase='CCC-LOOP-PLANNED-EXISTING-CNCL: '
            buildModificationNeededDescriptor $descriptorBase $1 $2
        fi
    elif [[ (( $cccCalID != ${clinicToCallCenterCalAssociater[$ccCalID]} )) || $cccDatetime != $ccDatetime ]]; then
        appointmentRSCneeded+=( $2 )
        descriptorBase='CCC-LOOP-RSC-NEEDED: '
        buildModificationNeededDescriptor $descriptorBase $1 $2
        if [[ $cccFirstName != $ccFirstName || $cccLastName != $ccLastName || $cccNote != $ccNote ]]; then appointmentModNeeded+=( $2 ); fi
    elif [[ $cccFirstName != $ccFirstName || $cccLastName != $ccLastName || $cccNote != $ccNote || (( $cccAppTypeID != $ccAppTypeID )) ]]; then
        appointmentModNeeded+=( $2 )
        descriptorBase="CCC-LOOP-MOD-NEEDED: "
        buildModificationNeededDescriptor $descriptorBase $1 $2
    fi
}
function genRandom() { eval "echo -n \$(( \${\${RANDOM}:3:1} + 1 ))" }
function checkForNeededSameDayModifications() {
# [12794227]="Consult" [29491003]="Rescheduled on Consult Calendar" [29284618]="Consult - Planned Cancel/No Show"  [29285605]="Existing Cancel"  [31180867]="Consult No Show Incorrect (Left Before Seen)" [26082046]"Consult No Show Incorrect (Call Center Error/Therapy/Wrong Clinic/Etc.)" [29423703]="Consult No Show Incorrect (Clinical Error/Staffing)" [31112876]="Clinic Canceled Consult" [31510097]="Rescheduled by Clinic to Future Date"
    buildSingleCallCenterVariables $1
    buildSingleClinicCopyVariables $2
    cccSameDay=$1
    ccSameDay=$2
    
    case $sameDayCCappTypeIDs[$ccSameDay] in
        29423703|31180867|26082046|31112876|31694690); sameDayPersistentPriority=4;;
        29491003|31510097); sameDayPersistentPriority=3;;
        29285605|29284618); sameDayPersistentPriority=2;;
        12794227); sameDayPersistentPriority=1;;
        *); sameDayPersistentPriority=0;;
    esac

    declare -i NEXTDAY
    NEXTDAY=$( date -j -v +1d -v -7H "+%s" )

    
    if [[ $ccCanceledStatus == true && $cccCanceledStatus == false ]] && (( $ccAppTypeID != 29284618 )); then
        sameDayCCappTypeIDs[$2]=31112876
        clinicCanceledConsults+=( $1 )
        persistentAppTypeIDs[$1]=31112876
    elif [[ $cccCanceledStatus == true && $ccCanceledStatus == false ]] && (( $ccAppTypeID != 29284618 )); then
        sameDayCCappTypeIDs[$2]=31694690
    elif [[ ! "${persistentUnixTimes[$associatedIDs[$cccSameDay]]}" ]]; then
        echo "No CCC information found: $cccSameDay" >> ./decision-array-values/debugging-data.txt
    elif (( $ccAppointmentUnixTime > $NEXTDAY )); then
        sameDayCCappTypeIDs[$2]=29491003
    elif [[ "${associatedIDs[$cccSameDay]}" ]] \
    && (( ${persistentUnixTimes[$associatedIDs[$cccSameDay]]} > $NEXTDAY )); then
        sameDayCCappTypeIDs[$2]=31510097
    elif (( $cccLabelID == 7732202 && sameDayPersistentPriority < 2 )); then
        sameDayCCappTypeIDs[$2]=29284618
    fi
    
    case $sameDayCCappTypeIDs[$ccSameDay] in
        29423703|31112876|26082046|31112876|31694690); sameDayPersistentPriority=4;;
        29491003|31510097); sameDayPersistentPriority=3;;
        29285605|29284618); sameDayPersistentPriority=2;;
        12794227); sameDayPersistentPriority=1;;
        *); sameDayPersistentPriority=0;;
    esac
    
    case $ccAppTypeID in
        29423703|31112876|26082046|31112876|31694690); sameDayCurrentPriority=4;;
        29491003|31510097); sameDayCurrentPriority=3;;
        29285605|29284618); sameDayCurrentPriority=2;;
        12794227); sameDayCurrentPriority=1;;
        *); sameDayCurrentPriority=0;;
    esac
    
    if [[ ! $cccSameDay || ! $ccSameDay ]]; then
        echo "\n$errorbar\nSAME DAY IDS NOT IMPORTING CORRECTLY\n$errorbar\n\n" >> commanderrors.txt
        echo "Same Day CCC ID: $cccSameDay\nSame Day CC ID: $ccSameDay" >> commanderrors.txt
    elif [[ ! $sameDayCurrentPriority || ! $sameDayPersistentPriority ]]; then
        echo "\n$errorbar\nAPPOINTMENT TYPE ID PRIORITIES NOT MAPPING CORRECT\n$errorbar\n\n" >> commanderrors.txt
        echo "Same Day Current Priority: $sameDayCurrentPriority\nSame Day Persistent Priority: $sameDayPersistentPriority" >> commanderrors.txt
        echo "Same Day Current App Type ID: ${persistentAppTypeIDs[$ccSameDay]}\nSame Day Persistent App Type ID: ${importSameDayCCappTypeIDs[$ccSameDay]}" >> commanderrors.txt
        
    elif (( ${cccIDs[(ie)$cccSameDay]} > ${#cccIDs} || ${ccIDs[(ie)$ccSameDay]} > ${#ccIDs} )) \
    || [[ ! "${persistentAppTypeIDs[$cccSameDay]}" || ! "${persistentAppTypeIDs[$ccSameDay]}" ]]; then
        echo "\n$errorbar\nCC SAME DAY OR CCC SAME DAY NOT FOUND IN DECSION MAP\n$errorbar\nCC Same Day: $ccSameDay\nCCC Same Day: $cccSameDay\n" >> commanderrors.txt
    elif (( $sameDayCurrentPriority > $sameDayPersistentPriority )); then
        persistentAppTypeIDs[$2]=sameDayCCappTypeIDs[$2]
    elif (( $sameDayCurrentPriority <= $sameDayPersistentPriority && $ccAppTypeID != ${sameDayCCappTypeIDs[$ccSameDay]} )) \
    && [[ "$ccCanceledStatus" != "true" ]]; then
        dataString="{\"appointmentTypeID\": ${sameDayCCappTypeIDs[$ccSameDay]} }"
        subCommandString=$( acuityCommand --command-name apply-appointment-modification --dataString $dataString --id $ccSameDay --string-only )
        subCommandResults=$( acuityCommand --command-name apply-appointment-modification --dataString $dataString --id $ccSameDay )
        buildStandardResultArrays $subCommandResults
        errorMessage="Adjust appointment type same day"
        changeType="Adjusted appointment type to ${sameDayCCappTypeIDs[$ccSameDay]}"
        parseResultsForOutput --command $subCommandString --result $subCommandResults --output ./adjusted-same-day.csv --error $errorMessage -S "changeType"
        persistentAppTypeIDs[$2]=$sameDayCCappTypeIDs[$2]
    elif (( $sameDayCurrentPriority <= $sameDayPersistentPriority )); then
        echo $ccSameDay $sameDayCCappTypeIDs[$2] $ccAppTypeID $ccCanceledStatus >> ./decision-array-values/debugging-data.txt
    elif [[ ! "${clinicCalIDs[(ie)$ccCalID]}" ]]; then
        echo "\n$errorbar\nSAME DAY DECISION MAP UNKNOWN CCCAL ID $ccCalID\n$ccSameDay" >> commanderrors.txt
    elif (( ${clinicCalIDs[(ie)$ccCalID]} > ${#clinicCalIDs} )); then
        qaMessage="Same day appointment has been rescheduled to non consult or therapy calendar. Please investigate and have the matching clinic copy/call center appointment moved to the correct calendar. This message will loop hourly till addressed"
        errorMessage="SAME DAY CONSULT RESCHEDULED TO NEW CALENDAR - NON-CONSULT\n$errorbar\nCCC ID: $cccSameDay\nCCID: $ccSameDay\n$cccCalID\n$ccCalID"
        echo $errorMessage >> commanderrors.txt
    elif (( $cccCalID != ${clinicToCallCenterCalAssociater[$ccCalID]} )); then
        qaMessage="Same day appointment has been rescheduled to different calendar. Please investigate and have the matching clinic copy/call center appointment moved to the correct calendar. This message will loop hourly till addressed"
        errorMessage="SAME DAY CONSULT RESCHEDULED TO NEW CALENDAR\n$errorbar\n"
        postToQA $1 "CCC" $qaMessage $errorMessage
    elif [[ $cccAppStartTime != $ccAppStartTime ]]; then
        dataString="{ \"datetime\": \"$cccDatetime\" }"
        errorMessage="Adjust appointment time same day"
        changeType="Adjusted appointment time from $ccAppStartTime to $cccAppStartTime"
        subCommandString=$( acuityCommand --command-name apply-appointment-modification --dataString $dataString --id $ccSameDay --string-only )
        subCommandResults=$( acuityCommand --command-name apply-appointment-modification --dataString $dataString --id $ccSameDay )
        buildStandardResultArrays $subCommandResults
        parseResultsForOutput --command $subCommandString --result $subCommandResults --output ./adjusted-same-day.csv --error $errorMessage -S "changeType"
    fi
}
buildShowRateData() {
    buildSingleClinicCopyVariables $1
    ccID=$1
    
    if [[ "${ccID}" ]] && (( $ccAppointmentUnixTime < $( date -j -v -15M +%s ) )); then
        case "$ccLabelID" in
            2629966|6664157|2758427|2690387)
                sameDayClinicShowsCount[$ccCalID]=$(( $sameDayClinicShowsCount[$ccCalID] + 1 ))
                sameDayIncludedTotalAppsCount[$ccCalID]=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                sameDayGrandTotalAppIDs+=( [$ccID]=true )
                sameDayAppIDstatuses+=( [$ccID]="Show" )
                ;;
            2795228|7732202)
                case $ccAppTypeID in
                    29284618|29285605|12794227)
                        sameDayIncludedTotalAppsCount[$ccCalID]=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="No Show" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=true )
                        ;;
                    29491003|31510097)
                        sameDayRescheduledCount[$ccCalID]=$(( $sameDayRescheduledCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="Rescheduled" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=false )
                        ;;
                    31112876)
                        sameDayClinicCanceledCount[$ccCalID]=$(( $sameDayClinicCanceledCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="Clinic Canceled Same Day - Report to Team Lead" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=false )
                        ;;
                    31694690)
                        sameDayCallCenterCanceledCount[$ccCalID]=$(( $sameDayCallCenterCanceledCount[$ccCalID] + 1 ))
                        sameDayIncludedTotalAppsCount[$ccCalID]=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="Call Center Canceled Same Day - Report to Team Lead" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=true )
                        ;;
                    29423703|26082046)
                        sameDayNSincorrectCount[$ccCalID]=$(( $sameDayNSincorrectCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="${persistentAppTypeNames[$ccID]}" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=false )
                        ;;
                    31180867)
                        sameDayIncludedTotalAppsCount=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayClinicShowsCount[$ccCalID]+=$( $sameDayClinicShowsCount[$ccCalID] + 1 )
                        sameDayAppIDstatuses+=( [$ccID]="Show (NS Incorrect - Should Have Been Show)" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=true )
                        ;;
                    *)
                        sameDayIncludedTotalAppsCount[$ccCalID]=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayGrandTotalAppIDs+=( [$ccID]=true )
                        sameDayAppIDstatuses+=( [$ccID]="No Show" )
                        ;;
                esac
                ;;
            *)
                case $ccAppTypeID in
                    29284618|29285605|12794227)
                        sameDayIncludedTotalAppsCount[$ccCalID]=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayUntaggedCount[$ccCalID]=$(( $sameDayUntaggedCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="Unlabeled (${ccAppTypeName})" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=true )
                        ;;
                    29491003|31510097)
                        sameDayRescheduledCount[$ccCalID]=$(( $sameDayRescheduledCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="Rescheduled" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=false )
                        ;;
                    31112876)
                        sameDayClinicCanceledCount[$ccCalID]=$(( $sameDayClinicCanceledCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="Same Day Clinic Canceled Consult" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=false )
                        ;;
                    31694690)
                        sameDayCallCenterCanceledCount[$ccCalID]=$(( $sameDayCallCenterCanceledCount[$ccCalID] + 1 ))
                        sameDayIncludedTotalAppsCount[$ccCalID]=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayUntaggedCount[$ccCalID]=$(( $sameDayUntaggedCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="Unlabeled (Call Center Canceled - Report to Team Lead)" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=true )
                        ;;
                    29423703|26082046)
                        sameDayNSincorrectCount[$ccCalID]=$(( $sameDayNSincorrectCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="${persistentAppTypeNames[$ccID]}" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=false )
                        ;;
                    31180867)
                        sameDayIncludedTotalAppsCount=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayClinicShowsCount[$ccCalID]+=$( $sameDayClinicShowsCount[$ccCalID] + 1 )
                        sameDayAppIDstatuses+=( [$ccID]="Show (NS incorrect - Should Have Been Show)" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=true )
                        ;;
                    *)
                        sameDayUntaggedCount[$ccCalID]=$(( $sameDayUntaggedCount[$ccCalID] + 1 ))
                        sameDayIncludedTotalAppsCount[$ccCalID]=$(( $sameDayIncludedTotalAppsCount[$ccCalID] + 1 ))
                        sameDayGrandTotalCount[$ccCalID]=$(( $sameDayGrandTotalCount[$ccCalID] + 1 ))
                        sameDayAppIDstatuses+=( [$ccID]="Unlabeled ${ccAppTypeName}" )
                        sameDayGrandTotalAppIDs+=( [$ccID]=true )
                        ;;
                esac
                ;;
        esac
    else
        echo $ccID >> ./decision-array-values/debugging-data.txt
    fi
}
function buildShowRateJsonReturn() {


    declare -i subInt

    subInt=1
    jsonString='{"date":"'$( date -v "-${dateInt}d" -v -7H +'%Y%m%d' )'","data":['
    updateTime=$( date +'%Y-%m-%d %H:%M:%S%z' )
    for calID total in "${(kv@)sameDayIncludedTotalAppsCount}"; do
        if [[ "${calID}" ]]; then
            jsonString+='{"timeUpdated":"'"$updateTime"'",'
            jsonString+='"calendarID":'"$calID,"
            jsonString+='"calendarName":'"\"$(
                if [[ "${clinicCopyCalNames[$calID]}" ]]; then echo -n ${clinicCopyCalNames[$calID]}; else echo -n 0; fi )\", "
            jsonString+='"showsCount":'"$(
                if [[ "${sameDayClinicShowsCount[$calID]}" ]]; then echo -n ${sameDayClinicShowsCount[$calID]}; else echo -n 0; fi ), "
            jsonString+='"untaggedCount":'"$(
                if [[ "${sameDayUntaggedCount[$calID]}" ]]; then echo -n ${sameDayUntaggedCount[$calID]}; else echo -n 0; fi ), "
            jsonString+='"rescheduledCount":'"$(
                if [[ "${sameDayRescheduledCount[$calID]}" ]]; then echo -n ${sameDayRescheduledCount[$calID]}; else echo -n 0; fi ), "
            jsonString+='"noShowIncorrectCount":'"$(
                if [[ "${sameDayNSincorrectCount[$calID]}" ]]; then echo -n ${sameDayNSincorrectCount[$calID]}; else echo -n 0; fi ), "
            jsonString+='"clinicCanceledCount":'"$(
                if [[ "${sameDayClinicCanceledCount[$calID]}" ]]; then echo -n ${sameDayClinicCanceledCount[$calID]}; else echo -n 0; fi ), "
            jsonString+='"sameDayCallCenterCanceledCount":'"$(
                if [[ "${sameDayCallCenterCanceledCount[$calID]}" ]]; then echo -n ${sameDayCallCenterCanceledCount[$calID]}; else echo -n 0; fi ), "
            jsonString+='"totalAppointmentsCount":'"$(
                if [[ "${sameDayIncludedTotalAppsCount[$calID]}" ]]; then echo -n ${sameDayIncludedTotalAppsCount[$calID]}; else echo -n 0; fi ), "
            jsonString+='"grandTotalAppointmentsCount":'"$(
                if [[ "${sameDayGrandTotalCount[$calID]}" ]]; then echo -n ${sameDayGrandTotalCount[$calID]}; else echo -n 0; fi )"
            if [[ "$subInt" == "${#sameDayIncludedTotalAppsCount}" ]]
                then jsonString+="}"
                else jsonString+="},"
            fi
        fi
        subInt+=1
    done
    jsonString+=']}'
    
    echo "$jsonString" > clinic-show-rate-data.json
    
    subInt=1
    jsonString='{"date":"'$( date -v "-${dateInt}d" -v -7H +'%Y%m%d' )'","data":['
    for ccID included in "${(kv@)sameDayGrandTotalAppIDs}"; do
        if [[ "${persistentCalIDs[$ccID]}" ]]; then
            jsonString+='{"timeUpdated":"'"$updateTime"'",'
            jsonString+='"id":'"$ccID,"
            jsonString+='"included":'"$included,"
            jsonString+='"status":'"\"${sameDayAppIDstatuses[$ccID]}\","
            jsonString+='"calendarName":'"\"${persistentCalNames[$ccID]}\","
            jsonString+='"calendarID":'"${persistentCalIDs[$ccID]},"
            jsonString+='"firstName":'"\"${persistentFirstNames[$ccID]}\","
            jsonString+='"lastName":'"\"${persistentLastNames[$ccID]}\","
            jsonString+='"appStartTime":'"\"${persistentAppStartTimes[$ccID]}\""
            if [[ "$subInt" == "${#sameDayGrandTotalAppIDs}" ]]
                then jsonString+="}"
                else jsonString+="},"
            fi
        else echo $ccID >> commanderrors.txt
        fi
        subInt+=1
    done
    jsonString+="]}"
    
    echo $jsonString > appointment-show-rate-data.json
}
