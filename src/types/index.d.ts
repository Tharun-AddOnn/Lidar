interface Lidar{
    /**
     * Method to check whether the Lidar sensor is available or not.
     */
    isLiDARAvailable(): void;
    // Next will work only on iOS

    startScanning():void;
}