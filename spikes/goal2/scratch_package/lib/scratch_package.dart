/// Marker exported by the disposable Goal 2 workspace package.
const workspaceProbeLabel = 'resolved-from-scratch-package';

/// Produces deterministic text that the scratch app can assert at runtime.
String describeWorkspaceResolution(String route) =>
    '$workspaceProbeLabel:$route';
