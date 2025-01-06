import os
import re
import subprocess

# Destination folder for downloads
DESTINATION = "/notebooks/private/models/Lora"

# Ensure the destination directory exists
os.makedirs(DESTINATION, exist_ok=True)

# List of Google Drive file URLs
FILE_LINKS = [
    "https://drive.google.com/file/d/1zeXzPaAtmxdG6Kik0Azn9C_zqsKcjK5Y/view?usp=drive_link",
"https://drive.google.com/file/d/1jQDIN9Y2U9wJK5XYfKn7CFnYlVFTvdRz/view?usp=drive_link",
"https://drive.google.com/file/d/1hWjXnEwLljPqHaKt6XvUPeww1m7soUm6/view?usp=drive_link",
"https://drive.google.com/file/d/1DzCutYqPOae6E35MnLf6w_ujP0qI9vXl/view?usp=drive_link",
"https://drive.google.com/file/d/1Lej8aLidMBG2DRT2xLUm4cTVdB6mVabM/view?usp=drive_link",
"https://drive.google.com/file/d/1bwKCkJ4BQ7LNOORzZi5ViCoJPmvEuRuv/view?usp=drive_link",
"https://drive.google.com/file/d/1oU0hHuzcAHgE5CzUxGkfJc3cFzL1EjMl/view?usp=drive_link",
"https://drive.google.com/file/d/1qlLlc42pbpJI36IWOsPR75_z1rot52Jl/view?usp=drive_link",
"https://drive.google.com/file/d/1uXMf7GIShyaDulB-aXqh-pYDTUQB86jH/view?usp=drive_link",
"https://drive.google.com/file/d/12baWrUE-azplmyy6hUgYvuBSQw2YKvRa/view?usp=drive_link",
"https://drive.google.com/file/d/1bXF39_Wt9h2TZoTmXEOKca5SDWgqpM7e/view?usp=drive_link",
"https://drive.google.com/file/d/1b7vShqoJkYbMEKS-nP1Po92LHZWKxux4/view?usp=drive_link",
"https://drive.google.com/file/d/1x5CGwOQPqudTmxDhSBzug5hNVbmZKcIO/view?usp=drive_link",
"https://drive.google.com/file/d/1Mg1eJPA5R3CUE2qReJX2SJMRN3-aKqoS/view?usp=drive_link",
"https://drive.google.com/file/d/1G2bc6UAqtsSsezhHVOa95rOqOw34WgIx/view?usp=drive_link",
"https://drive.google.com/file/d/1jxC7r25u8cnQ29ng3xRUHUxTkYkZ4CrL/view?usp=drive_link",
"https://drive.google.com/file/d/1x8bBsPbcQR6g0fNDZQf9ZceBlnmLcnwc/view?usp=drive_link",
"https://drive.google.com/file/d/1w4qI9XpVfpTmelnNPSvin7EqguEzFCdV/view?usp=drive_link",
"https://drive.google.com/file/d/13c9uICdMapoBPYwapnySnwTm6PG1MXdx/view?usp=drive_link",
"https://drive.google.com/file/d/10kVRDkBtuZvgBAzHInAIqYv8MeSXKmhl/view?usp=drive_link",
"https://drive.google.com/file/d/1y2jWmAkSRJXsjXmQV0TspzNzhe8y2F92/view?usp=drive_link",
"https://drive.google.com/file/d/15eQjvaaZBAdsWi94Qr3VeXmkdYvTyhC7/view?usp=drive_link",
"https://drive.google.com/file/d/1bUOuACSfI4vYMVgZsVv9anTkpxy67LQx/view?usp=drive_link",
"https://drive.google.com/file/d/18XbuaxPHiOB_7iZgdsuo8Fvb4MzorNnQ/view?usp=drive_link",
"https://drive.google.com/file/d/1gEFD7QzmvJ23pamfVKs06Lc_1r4dxpQ8/view?usp=drive_link",
"https://drive.google.com/file/d/1MoRBCHV87B2DVJJwwUo__rUuHbnsjT_g/view?usp=drive_link",
"https://drive.google.com/file/d/1La3VF-Tz1JjG2_Hqxwb2FqKltl9ygzYI/view?usp=drive_link",
"https://drive.google.com/file/d/1HnV9HQPcS5_uYHUJGNmtPz5c2itV0BWd/view?usp=drive_link",
"https://drive.google.com/file/d/1BrR6QRY0f4_Z6GsVBLGP5ssTgTf0sBlK/view?usp=drive_link",
"https://drive.google.com/file/d/1wSqeT2cFbJwPXP_ScVgKUBtkhSHuVun4/view?usp=drive_link",
"https://drive.google.com/file/d/1YWEk6pZgG7FahhduogEVMmPwdstnS_YW/view?usp=drive_link",
"https://drive.google.com/file/d/1GpRaHi-7DQDnROEcTNTb7I14IK5aHMRf/view?usp=drive_link",
"https://drive.google.com/file/d/1MSCk_YfKiqh652eUYaRSfIBUgwoa0ICt/view?usp=drive_link",
"https://drive.google.com/file/d/1wrzeBmgLKVCO1bs_00UOLAJWDpt4pftE/view?usp=drive_link",
"https://drive.google.com/file/d/1aCalZeWwg3mJ_KW4Tq4hvc_HwzPyA94z/view?usp=drive_link",
"https://drive.google.com/file/d/1an2a8LB8BHHCWbPx5Q3HE2E_AF0YkYLd/view?usp=drive_link",
"https://drive.google.com/file/d/1W2Xc7GyPxoo_vfri3MM2JZQx9ACr52f-/view?usp=drive_link",
"https://drive.google.com/file/d/1ZEDGMTinYML8ZwQlxjX4aJJIpbogUp6J/view?usp=drive_link",
"https://drive.google.com/file/d/1GgaqpduguRdPRCV23k3kIWwTDW7gmfaa/view?usp=drive_link",
"https://drive.google.com/file/d/1QEW3gK4Ce6J5Hfa5r_ytLyioMItcyDzo/view?usp=drive_link",
"https://drive.google.com/file/d/16df5Lt33iUjMCR-VGMIOeeEOUH8oe2ks/view?usp=drive_link",
"https://drive.google.com/file/d/1Ppp8CdD9jIawprvapEMrmxdcVeOPVvlh/view?usp=drive_link",
"https://drive.google.com/file/d/1TVtxPyH4M6WafMxPRNPcj-l2DfU6CQS9/view?usp=drive_link",
"https://drive.google.com/file/d/1KFa6Az0eBFB-sEkaG_o8eNCQB1igq3_V/view?usp=drive_link",
"https://drive.google.com/file/d/1t1t4Emyy_tkVBiTOwDjDAcdIIqczpDlh/view?usp=drive_link",
"https://drive.google.com/file/d/1Os5CbBOBGkjjxyxlgX5SSskGxnahk7Uf/view?usp=drive_link",
"https://drive.google.com/file/d/1v3scbY8fuMZJoBmTJ45w0cRmEhzm2DBj/view?usp=drive_link",
"https://drive.google.com/file/d/14iWEgztXgxD258QOG1eNcQBaIwMY7Kvq/view?usp=drive_link",
"https://drive.google.com/file/d/1WS9YanHP25nT6G_IFHGl_doJJifrmBdq/view?usp=drive_link",
"https://drive.google.com/file/d/1fxsmO0tluITxOOg6f4xaIYgyYeZ3s9OT/view?usp=drive_link",
"https://drive.google.com/file/d/1xh9M6ZQkVYW4c3GhOd-N4sp5QsLRysYk/view?usp=drive_link",
"https://drive.google.com/file/d/1RKnnrUaYeZN3KooWe6FBO8mFmLerN7Ja/view?usp=drive_link",
"https://drive.google.com/file/d/1xJbNvXDqLikldXLSmW_qadSL5hPLNckv/view?usp=drive_link",
"https://drive.google.com/file/d/1DhhzoFhnbSzBNerJ0CY9PIZwdMZXq5kk/view?usp=drive_link",
"https://drive.google.com/file/d/1qF-UPFRbccpt6iS9tIn9f8ON_hxXp2W-/view?usp=drive_link",
"https://drive.google.com/file/d/1nJl3DpJHWLnrkVdCKzUMpUsO-HQJE84t/view?usp=drive_link",
"https://drive.google.com/file/d/1gABTKn794kU6y0_pOJeIy8x6n8o-9Lf_/view?usp=drive_link",
"https://drive.google.com/file/d/1T8bXnPlUfkEBCrrVIJB9iW-jnAKn9e1Q/view?usp=drive_link",
"https://drive.google.com/file/d/1inLYs-5rQe7McpACkQf127CVcmcdWarG/view?usp=drive_link",
"https://drive.google.com/file/d/1SploOdTUlRy9jaN9KzYAsTMcKbLxLCHs/view?usp=drive_link",
"https://drive.google.com/file/d/1yKiekCkvsEyheJibCuy_lJN0Ey0y5JiT/view?usp=drive_link",
"https://drive.google.com/file/d/1C6gnk6VnH9kRQblxjq-ODrJyGXcFih8x/view?usp=drive_link",
"https://drive.google.com/file/d/1Iu02msmmdX_Q5EEXXjnQv0JS14Dv7hq4/view?usp=drive_link",
"https://drive.google.com/file/d/1hPxTMxJ8bnRHAKMxn_nke5-bskXnSrOe/view?usp=drive_link",
"https://drive.google.com/file/d/1npeWAjUd2fDjUWbiWvqv7rIAYAABA7MA/view?usp=drive_link",
"https://drive.google.com/file/d/1zj_kEGWoUGgzIdlGHcdKREqVuHHOHU1I/view?usp=drive_link",
"https://drive.google.com/file/d/16Rc8JU-IlVV389D1aZyQO2nPIH56Igxh/view?usp=drive_link",
"https://drive.google.com/file/d/1eR9VuoGjaU24KGEnYBw3HIid3gNFSTRo/view?usp=drive_link",
"https://drive.google.com/file/d/1Oyyr384kQXzUKTlW-dXqK9Tnm36CTloE/view?usp=drive_link",
"https://drive.google.com/file/d/1hW0U1TqHKnrYlwdZMaxc7MjhGcDH5gBD/view?usp=drive_link",
"https://drive.google.com/file/d/1e-4C2yVM_tudnCD7zKfzpnbqgHiiSHpz/view?usp=drive_link",
"https://drive.google.com/file/d/1EUCHtbvALMYYvRDAznd9SsGSKBvFepB3/view?usp=drive_link",
"https://drive.google.com/file/d/1upPdSjp9ol5OXpuqw3Ib4A_SI-zv3rq5/view?usp=drive_link",
"https://drive.google.com/file/d/1ycUkeJJTWiNmZsNI1l-75S6MSCGNQ8We/view?usp=drive_link",
"https://drive.google.com/file/d/1_FkaHP6qF4ejMBI4s7kWCq1tkq1ZKzyq/view?usp=drive_link",
"https://drive.google.com/file/d/1XZHXNdagdj7cx7VYLAc5PiNwsZHUFiKk/view?usp=drive_link",
"https://drive.google.com/file/d/1rd8zkzcAILkwdOhUSWjMj1rEOrYt203z/view?usp=drive_link",
"https://drive.google.com/file/d/1aGHGuTml6X92ocsxl8GkwPVf-IGOBx2W/view?usp=drive_link",
"https://drive.google.com/file/d/1z4-ZBbRbLnW-OPvWwip6W9qIIvLc3RSX/view?usp=drive_link",
"https://drive.google.com/file/d/11GtFIUc5POyL1XXtlf2f1d4yme1I01Tf/view?usp=drive_link",
"https://drive.google.com/file/d/1oHrJCHG339ouebkrrcdXZp4Z6xEaMyT4/view?usp=drive_link",
"https://drive.google.com/file/d/1PhSKxRpjI1nE6TPacnwqJ48uQBgIrGzZ/view?usp=drive_link",
"https://drive.google.com/file/d/1SxbKWnL1ayu1bMPsYUjwQr5PugNOsP6t/view?usp=drive_link",
"https://drive.google.com/file/d/1mkEY9PhXRGKuNyv6uBmBHUxKnWOb47Qi/view?usp=drive_link",
"https://drive.google.com/file/d/1b6BpqLDAYpEoVpn2rh0LMiPdyLBiwsQ_/view?usp=drive_link",
"https://drive.google.com/file/d/1ae1mwhMxzjU9FHAE038Sq_DmSUl5k-2h/view?usp=drive_link",
"https://drive.google.com/file/d/1DiG9iCZXsDgC-FlG-Dr1McXP9YpaHJfX/view?usp=drive_link",
"https://drive.google.com/file/d/1KiQcEC439Zx38a-7ew_-M7XF22XgxxSs/view?usp=drive_link",
    # Add more URLs here...
]

def download_file(url):
    # Extract the file ID using regex
    match = re.search(r"/d/([^/]+)/", url)
    if match:
        file_id = match.group(1)
        print(f"Preparing to download file with ID: {file_id}")
        # Construct the direct download URL
        direct_url = f"https://drive.google.com/uc?export=download&id={file_id}"
        try:
            # Use wget to download the file with the original name
            command = [
                "wget",
                "-q",  # Quiet mode
                "--show-progress",  # Show download progress
                "--content-disposition",  # Use the original file name
                "-P", DESTINATION,  # Save to the destination directory
                direct_url,
            ]
            subprocess.run(command, check=True)
            print(f"Downloaded successfully: {file_id}")
        except subprocess.CalledProcessError:
            print(f"Failed to download: {url}")
    else:
        print(f"Invalid URL format: {url}")

# Loop through each URL and download the file
for url in FILE_LINKS:
    download_file(url)

print(f"All downloads completed. Files saved in: {DESTINATION}")
