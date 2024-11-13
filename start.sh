# Run the program (webui.sh) as 'creativeteam' user
echo "Starting Stable Diffusion Workspace..."
sudo -u creativeteam bash /notebooks/private/webui.sh

# Display the Gradio public link clearly
if grep -q 'http.*gradio.*' /notebooks/private/webui_output.log; then
    echo -e "\033[1;34m\n************************************************************\033[0m"
    echo -e "\033[1;34m* \033[1;97mYour Stable Diffusion Workplace is ready!\033[0m"
    echo -e "\033[1;34m* \033[1;97mUse the Public Gradio Link below to access it:\033[0m"
    echo -e "\033[1;34m* \033[1;97m$(grep -o 'http.*gradio.*' /notebooks/private/webui_output.log)\033[0m"
    echo -e "\033[1;34m************************************************************\033[0m"
else
    echo -e "\033[1;31mError: Could not find the Gradio public link in the output log.\033[0m"
fi
