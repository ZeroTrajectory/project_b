namespace Core.Load
{
    public enum ELoadType
    {
        Editor,
        /// <summary>
        /// AssetBundle
        /// </summary>
        StreamingAssets,
        /// <summary>
        /// For ALL Assets
        /// </summary>
        Remote,
        Resource,
        OBB,
        /// <summary>
        /// ��չ��
        /// </summary>
        ExtPack,
    }

    public enum ELoadStatus
    {
        Waiting,
        Loading,
        Loaded,
        LoadError,
        WaitDelete,
        Deleted,
    }

    public enum ELoadModel
    {
      EditorModel,
      AssetBundle,
    }
    
    public  enum LoaderAgentState
    {
        Wait,
        LoadDependency,
        LoadAssetAb,
        LoadAsset,
        Done
    }

}