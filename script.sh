#!/bin/bash

##### Printing the normal users #####
users=`awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd`

## getting the date of today
today_date=$(date +"%d/%m/%Y")

#### Looping inside the normal users ####

for user in $users
do

    #### Execlude the user Cloud and Orange_run from the loop ####
    if [[ "$user" == "cloud" ]] || [[ "$user" =~ "orange_run" ]] || [[ "$user" =~ "orange_build" ]]
    then

        echo "admin user $user"

    else
        ## getting the status of the user's password (P,NP or L)
        password_validation=$(passwd -S $user | awk '{print $2}')

        ## getting the column 5 from normal users (Email)
        email=$(getent passwd $user | awk -F':' '{gsub(",", "",$5); print $5}')

        ## getting the expiration date and converting its formal to dd/mm/YY
        expiry_date=$(date -d "$(chage -l $user | awk -F: 'NR==2{print $2}')" +"%d/%m/%Y")

        ## getting the warning date (14 days before the expiration)
        warning_date1=$(date -d "$(chage -l $user | awk -F: 'NR==2{print $2}') -14 days" +"%d/%m/%Y")
        
        ## getting the warning date 2 (7 days before the expiration)
        warning_date2=$(date -d "$(chage -l $user | awk -F: 'NR==2{print $2}') -7 days" +"%d/%m/%Y")
        
        ## getting the inactive date of the user
        account_inactive_date=$(date -d "$(chage -l $user | awk -F: 'NR==4{print $2}')" +"%d/%m/%Y")

        ## getting the inactive date of the user
        if [[ $account_expires_value =~ " never" ]]
        then
            echo "The value of account_expires for $user is \"never\""
        else
            account_inactive_date=$(date -d "$(chage -l $user | awk -F: 'NR==4{print $2}')" +"%d/%m/%Y")
        fi

        #### Checking if the status is (P)
        if [ $password_validation == "P" ]
        then

            #### Checking if today is the warning date 1
            if [[ $today_date == $warning_date1 ]]
            then
                    echo -e "Hello $user,\nThis is $ip machine,It's warning mail(1) kindly change your jumphost password before $expiry_date to avoid the user lock" | mutt -F ../.muttrcJumpserver -s "Expiration Password Date" -- $email

            #### Checking if today is the warining date 2
            elif [[ $today_date == $warning_date2 ]]
            then        
                    echo -e "Hello $user,\nThis is $ip machine,It's warning mail(2) kindly change your jumphost password before $expiry_date to avoid the user lock" | mutt -F ../.muttrcJumpserver -s "Expiration Password Date" -- $email
            
            #### Checking if today is the expiration day
            elif [[ $today_date == $expiry_date ]]
            then
                   
                    #### Locking the user account after 90 days from now

                    expiration_1=$(date -d +"1 days" +"%Y-%m-%d")

                    # Set the expiration date for the user account
                    if [[ $account_expires_value =~ " never" ]]
                    then
                        usermod -e $expiration_1 $user
                    else
                        echo "Account expires value has a value now"
                    fi
                    echo -e "Hello $user,\nThis is $ip machine,Your user password has been expired and It will be inactive in $expiration_1" | mutt -F ../.muttrcJumpserver -s "Expiration Password Date" -- $email
            
            
            elif [[ $today_date == $account_inactive_date ]]
            then

                ## It will change the user password status to be locked
                passwd -l $user
            
            else
                    echo "Something went wrong with date value"
            fi

        #### Checking if the status is (L)
        elif [ $password_validation == "L" ]
        then
                echo -e "Hello $user,\nThis is $ip machine,Your account has been locked" | ../.muttrcJumpserver -s "Expiration Password Date" -- $email

                function Deleting_User(){
                    killall -u $user
                    userdel $user
                    rm -rf /home/$user/
                    if [ $? -eq 0 ]
                    then
                        echo "$user has been deleted"
                    else
                        echo "$user failed to delete!"
                    fi
                }
                Deleting_User          
        

        #### Checking if the status is (NP)
        elif [[ $password_validation == "NP" ]]
        then
                echo -e "Hello $user,\nThis is $ip machine,Your account has no password, Please put a password to avoid the account lock" | mutt -F ../.muttrcJumpserver -s "Expiration Password Date" -- $email
                passwd -e $user
        
        else
                echo "Something went wrong with the status value" 
        
        fi
    fi
done