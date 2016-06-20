/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
	NativeModules,
	requireNativeComponent,
	DeviceEventEmitter,
  	View,
	
  	AlertIOS,
	TouchableHighlight,
	
	
} from 'react-native';

import Message from './app/views/Message'



import { AnimatedCircularProgress } from 'react-native-circular-progress';


var BatteryManager = require('NativeModules').BatteryManager;

var BP3LManager = require('NativeModules').BP3LManager






class helloRN extends Component {
  constructor(props) {
      super(props);
      this.state = {
    	  discoveryInfo: 'Goodbye World.' ,
		  connectInfo:{},
		  measureInfo:{}
       };
	
	
   }
  discover(){
  	 let self =this
	 let onDiscovery = function(info){
	  console.log('onDiscovery',info)
      //self.setState({batteryLevel: info.level});
      //self.setState({charging: info.isPlugged});
	  
      self.setState({discoveryInfo:info});
	  
    }
	  self._sub_discover = DeviceEventEmitter.addListener('BP3L_Discovery', onDiscovery);
	
      BP3LManager.startDiscover('',(info) => {
        //self.setState({discoveryInfo:info});
		
		console.log(info)
      });
	  
	  
	 // AlertIOS.alert(
	 // 	   'Sync Complete',
	 // 	   'All your data are belong to us.'
	 // 	  );
	  
  }
  connect(){
  	
   	let self =this
 	let oncConnect = function(info){
		// { msg: 'Connected', address: 'D05FB8418903', name: 'BP3L' }
 	  console.log('oncConnect',info)
       //self.setState({batteryLevel: info.level});
       //self.setState({charging: info.isPlugged});
	  
       self.setState({connectInfo:info});
	  
    }
	
  	self._sub_connect = DeviceEventEmitter.addListener('BP3L_Connect', oncConnect);

	let mac = this.state && this.state.discoveryInfo.address
	
    BP3LManager.connectDevice('',mac,(info) => {
       //self.setState({discoveryInfo:info});
	
		console.log(info)
    });
	
  }
  
  startMeasure(){
  	let self =this
	let onMeasure= function(info){
	  	console.log('onMeasure',typeof info, info)
		
		self.setState({measureInfo:info});
		
		
	 }
    self._sub_measure = DeviceEventEmitter.addListener('BP3L_Measure', onMeasure);
	 
  	let mac = this.state && this.state.connectInfo.address
	
      BP3LManager.startMeasure('',mac,(info) => {
        //self.setState({discoveryInfo:info});
	
  		console.log(info)
		
    });
	  
  }
  
  
  
  render() {
	 let self =this
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
		  
		  <Message></Message>
		  
		  
      
		  
		  
		<AnimatedCircularProgress
		  size={120}
		  width={15}
		  fill={100}
		  tintColor="#00e0ff"
		  backgroundColor="#3d5875" />
		  
		  
		  
  		<TouchableHighlight
          //onHideUnderlay={this._onUnhighlight}
          onPress={this.discover.bind(this)}
          //onShowUnderlay={this._onHighlight}
          style={[styles.button, this.props.style]}
          underlayColor="#a9d9d4">
		  
			  <Text style={{color: 'red'}} >
			    discover
			  </Text>	
		  
		  </TouchableHighlight>	  
		  
  		<TouchableHighlight
          //onHideUnderlay={this._onUnhighlight}
          onPress={this.connect.bind(this)}
          //onShowUnderlay={this._onHighlight}
          style={[styles.button, this.props.style]}
          underlayColor="#a9d9d4">
		  
			  <Text style={{color: 'red'}} >
			    connect
			  </Text>	
		  
		  </TouchableHighlight>	
		  
  		<TouchableHighlight
          //onHideUnderlay={this._onUnhighlight}
          onPress={this.startMeasure.bind(this)}
          //onShowUnderlay={this._onHighlight}
          style={[styles.button, this.props.style]}
          underlayColor="#a9d9d4">
		  
			  <Text style={{color: 'red'}} >
			    connect
			  </Text>	
		  
		  </TouchableHighlight>	
		  
		  
        <Text style={styles.instructions}>
		  discoveryInfo:
          {this.state.discoveryInfo.address }
        </Text>
        <Text style={styles.instructions}>
		  connectInfo:{this.state.connectInfo && this.state.connectInfo.address }
        </Text>
        <Text style={styles.instructions}>
		  measureInfo:{this.state.measureInfo.msg=='MeasureDoing' && this.state.measureInfo.pressure[0]}
		  {this.state.measureInfo.msg=='Error' && this.state.measureInfo.msg}
        </Text>
		  
		 
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  button: {
      borderRadius: 5,
      flex: 1,
      height: 20,
      alignSelf: 'stretch',
      justifyContent: 'center',
      overflow: 'hidden',
    },
    buttonText: {
      fontSize: 18,
      margin: 5,
      textAlign: 'center',
    },
});

AppRegistry.registerComponent('helloRN', () => helloRN);
