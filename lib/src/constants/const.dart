import 'dart:ui';

//Constants with local string, url, colors and declarations are declared it will also use for multilingual process.

const kPrimaryColor = Color(0xff23a3e1);
const buttonColor = Color(0xff3bbce3);
const orangeColor = Color(0xfff1a146);
const barColor = Color(0xff30b2b0);
const barMarkerColor = Color(0xffb3b3b3);
const invBorderColor = Color(0xff979797);
const invListBackgroundColor = Color(0xff383838);
const purpleColor = Color(0xff693e9e);
const borderColor = Color(0xffd5d5d5);
const dashboardThemeColor = Color(0xffc2cbf7);
const successGreenColor = Color(0xff16e38a);
const btnLightGreenColor = Color(0xff35ba80);

const btnLightbluColor = Color(0xff0bd9ee);

const btngreytbluColor = Color(0xfff1f7f8 );
const pistagreen = Color(0xffbef5cc);
const pistagreY = Color(0xff8A97A2);
const lightorange = Color(0xfff57d0ff);
const liorange = Color(0xfff57d0ff);
const liblue = Color(0xff65f2f9);
const thbblue = Color(0xff00696e);
const thbDblue = Color(0xff2F96BF);
const darkgreen = Color(0xff146e00);

const splashscreen_text = "LUMINATOR";

// Development release url
const devBaseUrl = "http://iotpro.io:8077";
//const devBaseUrl = "https://schnelliot.in/";

// Production release url
const prodBaseUrl = "https://schnelliot.in/";
//const prodBaseUrl = "https://schnelliot.in/";


//Image uploading url for production
const localAPICall = "http://seepl18.net.in:9091/iot/upload/img/";

// const app_username = "smartLumi@gmail.com";
// const app_password = "smartLumi";

const no_network = "Please check your Mobile Internet Connectivity";
const user_email = "User Email";
const user_password = "Password";
const validate_email = "Please enter the validate email";
const sign_in = "Login";
const qr_text = "SCAN QR CODE";

const devILMDeviceInstallationFolder = "lumismartLights";
const ILMDeviceInstallationFolder = "smartLights";

const devILMserviceFolderName = "forRepairILM";
const ILMserviceFolderName = "forServiceLuminodes";

const devCCMSserviceFolderName = "forRepairCCMS";
const CCMSserviceFolderName = "forServiceCCMS";

const devGWserviceFolderName = "forRepairGateway";
const GWserviceFolderName = "forServiceCCMS";

const ilm_deviceType = "lumiNode";
const ccms_deviceType = "CCMS";
const Gw_deviceType = "Gateway";

const session_expired = "Session expired!";
//test
const app_version = "Version 2.2.2";

// const smart_Username = "developer@schnellenergy.com";
// const smart_Password = "schnell";

// const prod_Username = "production@schnellenergy.com";
// const prod_Password = "LumiNode";

const device_toast_msg = "Unable to find device  ";
const device_toast_notfound = "  Kindly try another device";

//Const messages

const device_qr_nt_found = "No QRs Found";
const device_selec_regions = "Please select Region to start Installation.";
const app_logout = "Are you sure you want to Logout?";
const device_no_entry = "Please Enter Device";
const device_no_result = 'No results found';
const app_display_name = "Luminator";
const app_logout_msg = "Are you sure you want to exit Luminator?";
const app_logout_no = "NO";
const app_logout_yes = "YES";
const app_scan_qr= "SCAN QR";
const app_dashboard = 'Dashboard';
const app_device_list  = "Device List view";
const app_device_filters = 'Device Filters';
const app_reg_selec = "Please select Region to start Installation";
const app_fetch_loc = "Fetching your location.";
const app_loc_ward = "Your current location does not appear to be in the selected Ward";
const app_pls_wait ='Please wait ..';
const app_invalid_img ="Invalid Image Capture, Please recapture and try installation";
const app_geofence_nfound ="GeoFence Availability is not found with this Ward";
const app_unable_folder ="Unable to Find Folder Details";
const app_compat_one ="Device is not compatible with this Project.";
const app_compat_two =" Kindly try another one.";
const app_com_install ="Complete Installation";
const app_com_replace ="Complete Replacement";
const app_device_faulty ="Unable to Install. Device appears to be Faulty. Kindly try another one";
const app_device_invalid_credentials ="Invalid Device Credentials";
const app_device_image_cap ="Image not captured successfully! Please try again!";
const app_loc_per ="Kindly Enable App Location Permission";
const app_dev_img_uperror ="Device Installation Image Upload Error";
const app_dev_inst_success = "Installed Successfully";
const app_dev_cred_improper = "Device Credentials are improper, please check and retry";
const app_dev_nfound_two = "Kindly try another device";
const app_reg_nozones = "No Zones releated to this Region";
const app_reg_notfound= "Unable to find Region Details";
const app_no_network = "Please check your Mobile Internet Connectivity";
const app_no_ward_relation = "No Devices Directly Related to Ward";
const app_no_results = 'No results found';
const app_no_regions = "Region details is not accessed for you, please contact your manager";
const app_usr_invalid_cred = "Invalid credentials, Please try again.";
const app_log_email = "Log-In with User email and Password";
const app_no_email = "Please enter the email";
const app_validate_email = "Please enter the validate email";
const app_validate_pass = "Please enter the password";

const app_dev_offline_mode = "Device in Offline Mode";
const app_dev_loc_alert = 'Luminator Location Alert';
const app_dev_range_alert = 'Your are not in the Nearest Range to Controll or Access the Device';
const app_close_btn = 'Close';
const app_dev_on = "Device ON Successfully";
const app_dev_off = "Device Off Successfully";
const app_unab_procs = "Unable to Process, Please try again";
const app_qr_duplicate = "Duplicate QR Code";
const app_qr_invalid = "Invalid QR Code";
const app_dialog_cancel = "Cancel";
const app_dialog_replace = "Replace";
const app_dial_replace = 'Would you like to replace ';
const app_dial_replace_with = ' With ';
const app_dev_group_nfud = "Device EntityGroup Not Found";
const app_dev_not_compat_one = "Device is not compatible with this Project ";
const app_dev_not_compat_two = " Kindly try another one.";
const app_dev_img_upload_error = "Device Replacement Image Upload Error";
const app_dev_repl_comp = "Device Replacement Completed";
const app_dev_sel_details_one = "Selected Device Details";
const app_dev_sel_details_two = "Not Found";
const app_dev_unable_folder_details = "Unable to find Device Folder Details";
const app_dev_current_unable_folder_details = "Unable to find current Device Folder Details";
const app_dev_find_relation_details = "Unable to Find Related Devices";
const app_dev_find_dev_attr = "Unable to find device attributes";
const app_dev_find_dev_cred = "Unable to Fetch Device Credentials";



