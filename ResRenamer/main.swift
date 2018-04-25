//
//  main.swift
//  ResRenamer
//
//  Created by HYL on 2018/4/25.
//  Copyright © 2018年 HYL. All rights reserved.
//

import Foundation

// Usage
func printUsage() {
    print("""
Usage:
 ResRenamer PATH_TO_IMAGES_FOLDER
""")
}

// Input
func getInput() -> String {
    // 1
    let keyboard = FileHandle.standardInput
    // 2
    let inputData = keyboard.availableData
    // 3
    let strData = String(data: inputData, encoding: String.Encoding.utf8)!
    // 4
    return strData.trimmingCharacters(in: CharacterSet.newlines)
}

/**
 Main Process
 */
if CommandLine.arguments.count < 2 {
    printUsage()
    exit(0);
}

let path = CommandLine.arguments[1]

print("Path: \(path)");

let fileManager = FileManager.default;
// 1. check path
var isDirectory = ObjCBool(false);
let pathExist = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
if !isDirectory.boolValue || !pathExist {
    printUsage()
}

// 2. analyse images
guard let subPaths = fileManager.subpaths(atPath: path) else {
    print("\(path) is empty..");
    exit(0);
}

var imageNameToPathsDictionary = Dictionary<String, Array<String>>()
for subPath in subPaths {
    guard subPath.hasSuffix(".png") else {
        continue
    }
    let components = NSString(string: subPath).components(separatedBy: "@")
    guard components.count > 1 else {
        continue
    }
    var fullPaths = imageNameToPathsDictionary[components[0]] ?? []
    fullPaths.append(NSString(string: path).appendingPathComponent(subPath))
    imageNameToPathsDictionary[components[0]] = fullPaths
}

// 3. rename
let allKeys = imageNameToPathsDictionary.keys
var results = Set<String>()
for key in allKeys {
    print("输入'\(key)'对应的资源名(忽略就直接回车):")
    let imageName = getInput()
    guard imageName.lengthOfBytes(using: .utf8) > 0 else {
        continue
    }
    // 3.1 copy image
    let fullPaths = imageNameToPathsDictionary[key]!
    for fullPath in fullPaths {
        let targetPath = NSString(string: fullPath).replacingOccurrences(of: key, with: imageName)
        try? fileManager.copyItem(atPath: fullPath, toPath: targetPath)
        results.insert("'\(key)' -> '\(imageName)'")
    }
}

// 4. result
print("\n完成：")
for res in results {
    print("\(res)")
}
