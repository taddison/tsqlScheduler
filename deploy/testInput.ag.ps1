param(
    [string][parameter(mandatory=$true)] $agName
    ,[string][parameter(mandatory=$true)] $replica
    ,[string][parameter(mandatory=$true)] $agDatabase
)

# TODO
# check sys.availability_replicas to assert DB status accross AG
