import { Platform, Alert } from 'react-native';
import { ios_license, android_license } from './vesdk_license';

// Define type for VESDK
interface VideoEditorSDK {
  unlockWithLicense: (license: string) => Promise<void>;
  openEditor: (video: any) => Promise<any>;
}

// Try to get VESDK dynamically to avoid immediate reference errors
let VESDK: VideoEditorSDK | null = null;

// Function to initialize VESDK safely
const initVESDK = async () => {
  if (VESDK === null) {
    try {
      const VESDKModule = require('react-native-videoeditorsdk');
      VESDK = VESDKModule.VESDK;
    } catch (error) {
      console.error('Failed to import VESDK:', error);
      return false;
    }
  }
  return !!VESDK;
};

export const openVideoFromLocalPathExample = async (): Promise<void> => {
  try {
    // Initialize VESDK first
    const isSDKAvailable = await initVESDK();
    
    if (!isSDKAvailable || !VESDK) {
      throw new Error('Video Editor SDK could not be initialized');
    }
    
    // Get the license based on platform
    const license = Platform.OS === 'ios' ? ios_license : android_license;
    
    // Unlock with license
    await VESDK.unlockWithLicense(license);
    
    // Add a video from the assets directory
    const video = require('./cat.MOV');
    
    // Open the video editor
    const result = await VESDK.openEditor(video);

    if (result != null) {
      // The user exported a new video successfully
      console.log(result?.video);
    } else {
      // The user tapped on cancel
      return;
    }
  } catch (error: any) {
    console.error('Video Editor Error:', error);
    Alert.alert(
      "Error", 
      `Failed to open video editor: ${error.message || String(error)}`,
      [{ text: "OK" }]
    );
  }
};

