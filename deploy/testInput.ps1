param(
    [boolean][parameter(mandatory=$true)] $agMode
    ,[string][parameter(mandatory=$true)] $agName
    ,[string][parameter(mandatory=$true)] $server
    ,[string][parameter(mandatory=$true)] $replica
    ,[string][parameter(mandatory=$true)] $notifyOperator
    ,[string][parameter(mandatory=$true)] $database
    ,[string][parameter(mandatory=$true)] $agDatabase
)

# TODO:
# validate Server is connectable before proceeding

..\deploy\testInput.standalone -server $server -database $database -notifyOperator $notifyOperator

#if($agMode){..\deploy\testInput.ag}


