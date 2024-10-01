//
//  AnimateModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/24.
//

import Foundation
import SpriteKit

class AnimateModel {
    
    func runAttackAnimation5(on node: SKSpriteNode) {
        let frameDuration = 0.1
        
        let textures1 = (0..<6).map { SKTexture(imageNamed: "Attack_1 (0_\($0))") }
        
        let textures2 = (0..<3).map { SKTexture(imageNamed: "Attack_2 (0_\($0))") }
        
        let textures3 = (0..<3).map { SKTexture(imageNamed: "Attack_3 (0_\($0))") }
        
        let textures4 = (0..<10).map { SKTexture(imageNamed: "Attack_4 (0_\($0))") }
        
        let allTextures = textures1 + textures2 + textures3 + textures4
        
        let animation = SKAction.animate(with: allTextures, timePerFrame: frameDuration)
        
        node.run(animation)
    }
    
    func knightRunAttackAnimation(on node: SKSpriteNode) {
        let frameDuration = 0.1
        
        let textures = (0..<17).map { SKTexture(imageNamed: "Attack\($0)") }
        
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        
        node.run(animation)
    }
    
    func RedHairdRunAttackAnimation(on node: SKSpriteNode) {
        let frameDuration = 0.1
        
        let textures = (0..<20).map { SKTexture(imageNamed: "RedHairAttack\($0)") }
        
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        
        node.run(animation)
    }
    
    func runAttackAnimation4(on node: SKSpriteNode) {
        let frameCount = 10
        let frameDuration = 0.1
        let textures = (0..<frameCount).map { SKTexture(imageNamed: "Attack_4 (0_\($0))") }
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        node.run(animation)
    }
    
    func runAttackAnimation3(on node: SKSpriteNode) {
        let frameCount = 3
        let frameDuration = 0.1
        let textures = (0..<frameCount).map { SKTexture(imageNamed: "Attack_3 (0_\($0))") }
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        node.run(animation)
    }
    
    func runAttackAnimation2(on node: SKSpriteNode) {
        let frameCount = 3
        let frameDuration = 0.1
        let textures = (0..<frameCount).map { SKTexture(imageNamed: "Attack_2 (0_\($0))") }
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        node.run(animation)
    }
    
    func runAttackAnimation1(on node: SKSpriteNode) {
        let frameCount = 6
        let frameDuration = 0.1
        let textures = (0..<frameCount).map { SKTexture(imageNamed: "Attack_1 (0_\($0))") }
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        node.run(animation)
    }
    
    func runRunAnimation(on node: SKSpriteNode) {
        let frameCount = 14
        let frameDuration = 0.1
        let textures = (0..<frameCount).map { SKTexture(imageNamed: "Run (0_\($0))") }
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        let repeatAction = SKAction.repeatForever(animation)
        node.run(repeatAction, withKey: "runAnimation")
    }
    
    func idleAnimate(on node: SKSpriteNode) {
        let frameCount = 8
        let frameDuration = 0.3
        let textures = (0..<frameCount).map { SKTexture(imageNamed: "Idle (0_\($0))") }
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        let repeatAction = SKAction.repeatForever(animation)
        node.run(repeatAction, withKey: "idleAnimate")
    }
    
    func slimeWalkAnimate(on node: SKSpriteNode) {
        let frameCount = 8
        let frameDuration = 0.3
        let textures = (0..<frameCount).map { SKTexture(imageNamed: "Walk (0_\($0))") }
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        let repeatAction = SKAction.repeatForever(animation)
        node.run(repeatAction, withKey: "slimeWalkAnimate")
    }
    
    func slimeHurtAnimation(on node: SKSpriteNode) {
        let frameCount = 9
        let frameDuration = 0.3
        let textures = (0..<frameCount).map { SKTexture(imageNamed: "Hurt (0_\($0))") }
        let animation = SKAction.animate(with: textures, timePerFrame: frameDuration)
        node.run(animation)
    }
}
