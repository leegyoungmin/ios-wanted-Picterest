//
//  SavedModel+CoreDataProperties.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/28.
//
//

import Foundation
import CoreData


struct savedModel {
    var id: String?
    var meme: String?
    var file: String?
    var raw: String?
}

extension SavedModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedModel> {
        return NSFetchRequest<SavedModel>(entityName: "SavedModel")
    }

    @NSManaged public var id: String?
    @NSManaged public var memo: String?
    @NSManaged public var fileURL: String?
    @NSManaged public var rawURL: String?

}

extension SavedModel : Identifiable {

}
