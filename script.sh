#!/bin/bash

##### Printing the normal users #####
users="tst1"
ip=$(hostname -I)
## getting the date of today
today_date=$(date +"%d/%m/%Y")

#### Looping inside the normal users ####

for user in $users
do
        echo "$(date)>>> $user"

        ## getting the status of the user's password (P,NP or L)
        password_validation=$(passwd -S $user | awk '{print $2}')

        ## getting the column 5 from normal users (Email)
        email=$(getent passwd $user | awk -F':' '{gsub(",", "",$5); print $5}')

        ## getting the row 2 (Expiration date)
        get_expiry_date=$(chage -l $user | awk -F: 'NR==2{print $2}')
        ## 3mlt kda 34an lma bst5dm el format "%d/%m/%Y" by3tbr el %d hwa el month w el %m hwa el day
        
        ## getting the expiration date and converting its formal to dd/mm/YY
        expiry_date=$(date -d "${get_expiry_date}" +"%d/%m/%Y")

        ## getting the warning date (14 days before the expiration)
        warning_date1=$(date -d "${get_expiry_date} -2 days" +"%d/%m/%Y")
        
        ## getting the warning date 2 (7 days before the expiration)
        warning_date2=$(date -d "${get_expiry_date} -1 days" +"%d/%m/%Y")
        
        ## getting the inactive date of the user
        account_expiry_date=$(date -d "$(chage -l $user | awk -F: 'NR==4{print $2}')" +"%d/%m/%Y")

        #### Checking if the status is (P)
        if [[ $password_validation == "P" ]]
        then

            #### Checking if today is the warning date 1
            if [[ $today_date == $warning_date1 ]]
            then
                    echo -e "Hello $user,\nThis is $ip machine,It's warning mail(1) kindly change your jumphost password before $expiry_date to avoid the user lock" | mutt -F /home/amir.hossam/Desktop/.muttrcJumpserver -s "Expiration Password Date" -- $email

                    if [[ $? -eq 0 ]]
                    then
                        echo "$(date) >>> warning mail(1) has been sent"
                    else
                        echo "$(date) >>> warning mail(1) mail doesn't have been sent"
                    fi
            #### Checking if today is the warining date 2
            elif [[ $today_date == $warning_date2 ]]
            then        
                    echo -e "Hello $user,\nThis is $ip machine,It's warning mail(2) kindly change your jumphost password before $expiry_date to avoid the user lock" | mutt -F /home/amir.hossam/Desktop/.muttrcJumpserver -s "Expiration Password Date" -- $email

                    if [[ $? -eq 0 ]]
                    then
                        echo "$(date) >>> warning mail(2) has been sent"
                    else
                        echo "$(date) >>> warning mail(2) doesn't have been sent"
                    fi
            #### Checking if today is the expiration day
            elif [[ $today_date == $expiry_date ]]
            then
                   
                    #### Locking the user account after 90 days from now

                    expiration_date=$(date -d +"1 days" +"%Y-%m-%d")

                    # Set the expiration date for the user account
                    if [[ $account_expires_value =~ " never" ]]
                    then
                        #Setting a user expiry date on the date (expi)
                        usermod -e $expiration_date $user
                    else
                        echo "Account expires value is $accout_expires_value"
                    fi
                    echo -e "Hello $user,\nThis is $ip machine,Your user password has been expired and It will be inactive in $expiration_date" | mutt -F /home/amir.hossam/Desktop/.muttrcJumpserver -s "Expiration Password Date" -- $email
                    
                    
                    if [[ $? -eq 0 ]]
                    then
                        echo "$(date) >>> expiration mail has been sent"
                    else
                        echo "$(date) >>> expiration mail doesn't have been sent"
                    fi
            
            elif [[ $today_date == $account_expiry_date ]]
            then

                ## It will change the user password status to be locked
                passwd -l $user
            
            else
                    echo "Something went wrong with date value"
            fi

        #### Checking if the status is (L)
        elif [[ $password_validation == "L" ]]
        then
                echo -e "Hello $user,\nThis is $ip machine,Your account has been locked" | mutt -F /home/amir.hossam/Desktop/.muttrcJumpserver -s "Expiration Password Date" -- $email

                if [[ $? -eq 0 ]]
                then
                    echo "$(date) >>> account locked mail has been sent"
                else
                    echo "$(date) >>> account locked mail doesn't have been sent"
                fi
                
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
                echo -e "Hello $user,\nThis is $ip machine,Your account has no password, Please put a password to avoid the account lock" | mutt -F /home/amir.hossam/Desktop/.muttrcJumpserver -s "Expiration Password Date" -- $email
                
                if [[ $? -eq 0 ]]
                then
                    echo "$(date) >>> No password mail has been sent"
                else
                    echo "$(date) >>> No password mail doesn't have been sent"
                fi

                passwd -e $user
        
        else
                echo "Something went wrong with the user status value" 
        
        fi
done
