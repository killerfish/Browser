//
//  WebPageTabController.swift
//  Orion
//
//  Created by usman on 05/04/2023.
// 

import UIKit

class WebPageTabController: UIPageViewController {
  private var webViewControllerArray: [WebViewController] = [WebViewController()]
  private var currentPageIndex = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = self
    delegate = self
    setViewControllers([webViewControllerArray[0]], direction: .forward, animated: true, completion: nil)
  }

  func addWebViewController(_ webViewController: WebViewController) {
    let newViewController = WebViewController()
    webViewControllerArray.append(newViewController)
    setViewControllers([newViewController], direction: .forward, animated: true, completion: nil)
    currentPageIndex = webViewControllerArray.count - 1
  }

  func removeWebViewController() {
    guard webViewControllerArray.count > 1 else {
      return
    }

    var pageDirection: UIPageViewController.NavigationDirection = .forward
    webViewControllerArray.remove(at: currentPageIndex)
    if currentPageIndex == webViewControllerArray.count {
      currentPageIndex -= 1
      pageDirection = .reverse
    }
    
    let lastWebViewController = webViewControllerArray[currentPageIndex]
    setViewControllers([lastWebViewController], direction: pageDirection, animated: true, completion: nil)
  }
  
  func goBack() {
    let currentTabController = webViewControllerArray[currentPageIndex]
    currentTabController.navigateBack()
  }
}

extension WebPageTabController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = webViewControllerArray.firstIndex(of: viewController as! WebViewController), viewControllerIndex > 0 else {
      return nil
    }
    
    return webViewControllerArray[viewControllerIndex - 1]
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = webViewControllerArray.firstIndex(of: viewController as! WebViewController), viewControllerIndex < webViewControllerArray.count - 1 else {
      return nil
    }
    
    return webViewControllerArray[viewControllerIndex + 1]
  }
    
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    
    guard completed,
      let currentViewController = pageViewController.viewControllers?.first,
      let index = webViewControllerArray.firstIndex(of: currentViewController as! WebViewController)
      else {
        return
      }
    
    currentPageIndex = index
    (currentViewController as! WebViewController).updateNavigationStatus()
  }
}
