BEGIN {
    NEXTDATUM=0;
    DATUM="";
    SENSOR=0;
    }
{
    if ( $1 == "Datum") {
        NEXTDATUM=1;
        SENSOR=1
    } else {
 
        if ( NEXTDATUM==1) {
            DATUM=$1;
            SENSOR=1;
            NEXTDATUM=0;
        } else {
            if (SENSOR < 9) {
                if ( $1 != "--" ) {
                    print(SENSOR "," DATUM "," $1 "," $4 "," $2 "," $3 )} ;
                };
            SENSOR=SENSOR+1;    
        } ;
    };
    
}
