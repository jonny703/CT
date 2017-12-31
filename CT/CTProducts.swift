//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation

public struct CTProducts {
  
  public static let AlarmSet = "com.caesar.alarmset"
  
  fileprivate static let productIdentifiers: Set<ProductIdentifier> = [CTProducts.AlarmSet]

  public static let store = IAPHelper(productIds: CTProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
