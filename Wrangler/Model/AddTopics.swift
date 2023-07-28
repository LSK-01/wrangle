//
//  AddTopics.swift
//  Wrangler
//
//  Created by Luca Sarif-Kattan on 09/08/2018.
//  Copyright © 2018 Luca Sarif-Kattan. All rights reserved.
//

import Foundation
import Firebase

class addtopics{


        static func addtopics(){
            
            
            var topics:[String] = ["HEALTH & MEDICINE",
                                   "Medical Marijuana",
                                   "Euthanasia & Assisted Suicide",
                                   "Vaccines for Kids",
                                   "Abortion",
                                   "Vegetarianism",
                                   "Obesity is a disease",
                                   "Obamacare",
                                   "Right to Health Care",
                                   "EDUCATION",
                                   "School Uniforms",
                                   "Standardized Tests",
                                   "Tablets vs. Textbooks",
                                   "College Education is Worth it",
                                   "Banned Books",
                                   "POLITICS",
                                   "Death Penalty",
                                   "Drinking Age Should be Lowered",
                                   "Illegal Immigration",
                                   "Gun Control",
                                   "Recreational Marijuana",
                                   "Concealed Handguns",
                                   "SCIENCE & TECHNOLOGY",
                                   "Animal Testing",
                                   "Cell Phone Radiation is Real",
                                   "Alternative Energy vs. Fossil Fuels",
                                   "Climate Change",
                                   "Net Neutrality",
                                   "Police Body Cameras",
                                   "Bottled Water Ban",
                                   "ELECTIONS & PRESIDENTS",
                                   "Felon Voting",
                                   "Ronald Reagan",
                                   "Bill Clinton",
                                   "Voting Machines",
                                   "2016 Presidential Election",
                                   "Electoral College",
                                   "WORLD / INTERNATIONAL",
                                   "Israeli-Palestinian Conflict",
                                   "Cuba Embargo",
                                   "Drone Strikes Overseas",
                                   "SEX & GENDER",
                                   "Gay Marriage",
                                   "Prostitution Should be Legalized",
                                   "Born Gay? Origins of Sexual Orientation",
                                   "ENTERTAINMENT & SPORTS",
                                   "Cyberbullying Should Not be a Crime",
                                   "Video Games are Too Violent",
                                   "Drug Use in Sports",
                                   "Olympics",
                                   "National Anthem Protests",
                "Do you think that people should be allowed to do this that and the other even if",
            "OTHER"]
            
            let batch = Firestore.firestore().batch()
            var currentCategory: String!
            var categories: [String] = []
            
            for string in topics{
                
                //is a category
                if string.uppercased() == string{
                    currentCategory = string.formattedString(spaces:  true)
                    categories.append(currentCategory.formattedString(spaces:  true).capitalized)
                }
                else{
                //creating keywords object

                    let stringArr = string.components(separatedBy: " ")
                    let categoryArr = currentCategory.components(separatedBy: " ")
                    
                var keywordsObj: [String] = []
                    for keyword in categoryArr{
                        if Database.commonWords.contains(keyword.formattedString(spaces:  false)){
                            print("in arr")
                        }
                        else{
                            keywordsObj.append(keyword.lowercased())
                        }
                    }
                
                for keyword in stringArr{
                    if Database.commonWords.contains(keyword.formattedString(spaces:  false)) || keyword.formattedString(spaces:  false) == ""{
                        print("in arr")
                    }
                    else{
                        keywordsObj.append(keyword.lowercased())
                        print(keywordsObj)
                    }
                }
                
                    
                   let data = TopicFunctions.createTopicDataObjForDB(timeCreatedInSeconds: Date.getCurrentSeconds(), createdBy: "Wrangle", topicName: string, category: currentCategory.formattedString(spaces:  true).capitalized, keywords: keywordsObj)


                
                let document = Firestore.firestore().collection("topics").document(string.formattedString(spaces:  true).capitalized)
                batch.setData(data,
                              forDocument: document)
                
            }
            }
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                } else {
                    print("Batch write succeeded - writing categories")
                   /* for category in categories{
                        Database.addDocumentErrorHandling(path: "topicCategories", data: ["categoryName": category], completion: { (id, err) in
                            if let err = err {
                                print(err)
                                return
                            }
                            
                        })
                    }*/
                }
            }
    }
}
