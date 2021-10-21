#!/bin/sh

run_tfgraph_inside_subfolder()
{                                
    num=0;                       
    echo "----run_tfgraph_inside_subfolder---"
    PARENTDIR=`pwd`                              
    echo "PARENT="$PARENTDIR                     
                                                 
    for filename in `find . -name "*.hcl"`;      
    do                                     
            base=$(basename "$filename")   
            directory=$(dirname "$filename")
            echo $directory            
            cd $directory                   
            

            echo "directory="$directory 

            CURRENT_DIR=`pwd`               
            
	        if [ "$PARENTDIR" = "$CURRENT_DIR" ]; then
                echo "skip top folder"                
            else                                      
                    num=$(( $num + 1 ));              
                    echo "call terraform graph here.."   
                    terragrunt graph > $directory-graph.dot 
            fi;                                                                                                 
                    echo "#-----------------------#"                                                            
            cd -                                                                                              
                                                                                                                
    done;                                           
    if [ "$num" -gt 1 ]; then                       
        echo "subfolders found"
    else                       
        echo "no subfolders found"
        terraform graph > directory-graph.dot 

    fi;                                                                                         
                                                                                                                                                                                             
}

run_tfgraph_inside_subfolder

