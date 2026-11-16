#if canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#else
    import Darwin
#endif

/// The open-file limit (RLIMIT_NOFILE) of this process. Child processes inherit it.
enum OpenFileLimit {
    /// Raises the soft limit to `wanted`, never above the hard limit, and returns the soft limit in effect.
    static func raise(toAtLeast wanted: Int) -> Int {
        var limit = rlimit()
        guard getrlimit(resource, &limit) == 0 else {
            return 256
        }
        let current = Int(clamping: limit.rlim_cur)
        let target = min(rlim_t(wanted), limit.rlim_max)
        guard target > limit.rlim_cur else {
            return current
        }
        var raised = limit
        raised.rlim_cur = target
        return setrlimit(resource, &raised) == 0 ? Int(clamping: target) : current
    }

    #if canImport(Glibc)
        private static let resource = __rlimit_resource_t(RLIMIT_NOFILE.rawValue)
    #else
        private static let resource = RLIMIT_NOFILE
    #endif
}
