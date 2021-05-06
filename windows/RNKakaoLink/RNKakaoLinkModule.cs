using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Kakao.Link.RNKakaoLink
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNKakaoLinkModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNKakaoLinkModule"/>.
        /// </summary>
        internal RNKakaoLinkModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNKakaoLink";
            }
        }
    }
}
